//
//  NetworkCacheManager.swift
//  Caching
//
//  Created by RJ Heim on 6/1/25.
//

import CachingInterfaces
import Foundation
import SwiftUI

public final actor NetworkCacheManager: CacheManager {
    private let configuration: CacheConfiguration
    private let urlCache: URLCache
    private let session: URLSessionProtocol
    private let timeToLiveManager: TimeToLiveManager

    public init(configuration: CacheConfiguration = .default) {
        if let cacheDirectory = configuration.cacheDirectory,
           let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let cacheURL = URL(fileURLWithPath: documentsPath).appendingPathComponent(cacheDirectory)

            self.urlCache = URLCache(
                memoryCapacity: configuration.memoryCapacity,
                diskCapacity: configuration.diskCapacity,
                directory: cacheURL
            )
        } else {
            self.urlCache = URLCache(
                memoryCapacity: configuration.memoryCapacity,
                diskCapacity: configuration.diskCapacity
            )
        }

        // Create session with cache policy
        let config = URLSessionConfiguration.default
        config.urlCache = self.urlCache
        config.requestCachePolicy = .useProtocolCachePolicy

        self.configuration = configuration
        self.session = URLSession(configuration: config)
        self.timeToLiveManager = UserDefaults.timeToLiveManager()
    }

#if DEBUG

    init(
        configuration: CacheConfiguration,
        urlCache: URLCache,
        urlSession: URLSessionProtocol,
        timeToLiveManager: TimeToLiveManager
    ) {
        self.configuration = configuration
        self.urlCache = urlCache
        self.session = urlSession
        self.timeToLiveManager = timeToLiveManager
    }


    func isCached(url: URL) -> Bool {
        self.getCachedResponse(for: URLRequest(url: url)) != nil
    }

#endif

    // MARK: - Cache Management Methods
    private func cacheResponse(for request: URLRequest, response: URLResponse, data: Data) {
        let cachedResponse = CachedURLResponse(response: response, data: data)
        urlCache.storeCachedResponse(cachedResponse, for: request)
        guard let url = request.url else {
            return
        }
        timeToLiveManager.saveTimeToLive(url: url, timeToLive: configuration.timeToLive)
    }

    private func getCachedResponse(for request: URLRequest) -> CachedURLResponse? {
        guard let url = request.url,
              let timeToLiveDate = timeToLiveManager.getTimeToLive(url: url),
              timeToLiveDate > .now else {
            removeCachedResponse(for: request)
            return nil
        }
        return urlCache.cachedResponse(for: request)
    }

    private func removeCachedResponse(for request: URLRequest) {
        urlCache.removeCachedResponse(for: request)
    }

    // MARK: - Network Request with Caching
    public func fetchData(
        from url: URL,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    ) async throws(CachingNetworkError) -> Data {
        var request = URLRequest(url: url)
        request.cachePolicy = cachePolicy

        switch cachePolicy {
        case .useProtocolCachePolicy, .returnCacheDataElseLoad:
            return try await executeDefaultCachePolicy(request)

        case .reloadIgnoringLocalCacheData, .reloadIgnoringLocalAndRemoteCacheData, .reloadRevalidatingCacheData:
            return try await fetchDataAndCache(request)

        case .returnCacheDataDontLoad:
            if let cachedResponse = getCachedResponse(for: request) {
                return cachedResponse.data
            } else {
                throw CachingNetworkError.noCachedData
            }

        @unknown default:
            return try await executeDefaultCachePolicy(request)
        }
    }

    public func fetchImage(
        from url: URL,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    ) async throws(CachingNetworkError) -> Image {
        let data = try await fetchData(from: url, cachePolicy: cachePolicy)

        guard let image = UIImage(data: data) else {
            throw CachingNetworkError.invalidImageData
        }

        return Image(uiImage: image)
    }

    // MARK: - Cache Clear and Size
    public func clearCache() {
        urlCache.removeAllCachedResponses()
    }

    public func getCacheSize() -> (memory: Int, disk: Int) {
        return (urlCache.currentMemoryUsage, urlCache.currentDiskUsage)
    }
}

// MARK: - Cache Helper
extension NetworkCacheManager {
    private func executeDefaultCachePolicy(_ request: URLRequest) async throws(CachingNetworkError) -> Data {
        if let cachedResponse = getCachedResponse(for: request) {
            return cachedResponse.data
        } else {
            return try await fetchDataAndCache(request)
        }
    }

    private func fetchDataAndCache(_ request: URLRequest) async throws(CachingNetworkError) -> Data {
        do {
            let (data, response) = try await session.data(for: request, delegate: nil)

            // Cache the response if it's cacheable
            try shouldCacheResponse(response)

            cacheResponse(for: request, response: response, data: data)

            return data
        } catch {
            if let urlError = error as? URLError {
                throw CachingNetworkError.networkError(underlyingError: urlError)
            } else if let cachingError = error as? CachingNetworkError {
                throw cachingError
            } else {
                throw CachingNetworkError.unknownError(underlyingError: error)
            }
        }
    }

    private func shouldCacheResponse(_ response: URLResponse) throws {
        // TODO: Have specific throwing case for an incorrect response type.
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CachingNetworkError.invalidResponse(statusCode: -1)
        }

        guard configuration.acceptableResponseRange.contains(httpResponse.statusCode) else {
            throw CachingNetworkError.invalidResponse(statusCode: httpResponse.statusCode)
        }
    }
}
