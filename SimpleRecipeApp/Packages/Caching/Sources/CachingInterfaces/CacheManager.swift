//
//  CacheManager.swift
//  Caching
//
//  Created by RJ Heim on 6/1/25.
//

import Foundation
import SwiftUI

public protocol CacheManager: Actor {
    func fetchData(
        from url: URL,
        cachePolicy: URLRequest.CachePolicy
    ) async throws(CachingNetworkError) -> Data

    func fetchImage(
        from url: URL,
        cachePolicy: URLRequest.CachePolicy
    ) async throws(CachingNetworkError) -> Image

    func clearCache()
    func getCacheSize() -> (memory: Int, disk: Int)
}

public final actor MockCacheManager: CacheManager {
    private var cachedData: [URL: Data]
    private var imageData: [URL: Image]
    private let session: URLSession = .shared

    public init(cachedData: [URL : Data], imageData: [URL : Image]) {
        self.cachedData = cachedData
        self.imageData = imageData
    }

    public func fetchData(from url: URL, cachePolicy: URLRequest.CachePolicy) async throws(CachingNetworkError) -> Data {
        if let data = cachedData[url] {
            return data
        }
        do {
            let (data, _) = try await session.data(for: URLRequest(url: url))
            cachedData[url] = data
            return data
        } catch {
            throw .unknownError(underlyingError: error)
        }
    }
    
    public func fetchImage(from url: URL, cachePolicy: URLRequest.CachePolicy) async throws(CachingNetworkError) -> Image {
        if let image = imageData[url] {
            return image
        }

        let data: Data
        do {
            (data, _) = try await session.data(for: URLRequest(url: url))
        } catch {
            throw .unknownError(underlyingError: error)
        }

        guard let fetchedImage = Image(data: data) else {
            throw .invalidImageData
        }
        return fetchedImage
    }
    
    public func clearCache() {
        cachedData = [:]
        imageData = [:]
    }
    
    public func getCacheSize() -> (memory: Int, disk: Int) {
        if cachedData.isEmpty && imageData.isEmpty {
            return (0, 0)
        } else {
            return (100, 1000) // Not accurate but fine for mocking
        }
    }

}
