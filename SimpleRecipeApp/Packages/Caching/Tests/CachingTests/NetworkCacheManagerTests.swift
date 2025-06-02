//
//  NetworkCacheManagerTests.swift
//  Caching
//
//  Created by RJ Heim on 6/1/25.
//

@testable import Caching
import CachingInterfaces
import SwiftUI
import XCTest

class NetworkCacheManagerTests: XCTestCase {
    let testURL: URL = URL(string: "https://example.com/test-data")!
    var testData: Data = "Test response data".data(using: .utf8)!

    func testFetchDataSuccess() async throws {
        let mockSession = MockURLSessionProtocol()
        await mockSession.setupMock(url: testURL, data: testData)
        let cacheManager = NetworkCacheManager.createTestInstance(urlSessionProtocol: mockSession)

        let fetchedData = try await cacheManager.fetchData(from: testURL)

        XCTAssertEqual(fetchedData, testData, "Fetched data should match mock data")
    }

    func testFetchCacheSuccess() async throws {
        let mockSession = MockURLSessionProtocol()
        await mockSession.setupMock(url: testURL, data: testData)
        let cacheManager = NetworkCacheManager.createTestInstance(urlSessionProtocol: mockSession)

        let fetchedData = try await cacheManager.fetchData(from: testURL)

        XCTAssertEqual(fetchedData, testData, "Fetched data should match mock data")

        await mockSession.clearMocks()

        do {
            let cachedData = try await cacheManager.fetchData(from: testURL)
            XCTAssertEqual(cachedData, fetchedData)
        } catch {
            XCTFail("Should have data in the cache.")
        }
    }

    func testFetchDataFailureURLError() async {
        let expectedError = URLError(.unknown)
        let mockSession = MockURLSessionProtocol()
        await mockSession.setupMockError(url: testURL, error: expectedError)
        let cacheManager = NetworkCacheManager.createTestInstance(urlSessionProtocol: mockSession)

        do {
            _ = try await cacheManager.fetchData(from: testURL)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is CachingNetworkError, "Should throw CachingNetworkError")
            XCTAssertEqual((error.errorCode), 1)
        }
    }

    func testFetchDataFailure() async {
        let expectedErrorStatusCode: Int = 400
        let mockSession = MockURLSessionProtocol()
        await mockSession.setupMock(url: testURL, data: testData, statusCode: expectedErrorStatusCode)
        let cacheManager = NetworkCacheManager.createTestInstance(urlSessionProtocol: mockSession)

        do {
            _ = try await cacheManager.fetchData(from: testURL)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is CachingNetworkError, "Should throw CachingNetworkError")
            XCTAssertEqual((error.errorCode), expectedErrorStatusCode)
        }
    }

    func testFetchImageSuccess() async throws {
        let imageURL = URL(string: "https://example.com/test-image.png")!
        guard let catImage = Bundle.module.url(forResource: "cat", withExtension: "jpg") else {
            XCTFail("Failed to get cat jpg.")
            return
        }
        let imageData = try Data(contentsOf: catImage)
        let mockSession = MockURLSessionProtocol()
        await mockSession.setupMock(url: imageURL, data: imageData)
        let cacheManager = NetworkCacheManager.createTestInstance(urlSessionProtocol: mockSession)

        let fetchedImage = try await cacheManager.fetchImage(from: imageURL)

        XCTAssertNotNil(fetchedImage, "Should return a valid image")
    }

    func testFetchImageInvalidData() async {
        let imageURL = URL(string: "https://example.com/invalid-image")!
        let mockSession = MockURLSessionProtocol()
        await mockSession.setupMock(url: imageURL, data: testData)
        let cacheManager = NetworkCacheManager.createTestInstance(urlSessionProtocol: mockSession)

        do {
            _ = try await cacheManager.fetchImage(from: imageURL)
            XCTFail("Should have thrown an error for invalid image data")
        } catch {
            XCTAssertEqual(error, CachingNetworkError.invalidImageData, "Should throw invalidImageData error")
        }
    }

    // MARK: - Cache Policy Tests

    func testCachePolicyReturnCacheDataElseLoad() async throws {
        let mockSession = MockURLSessionProtocol()
        await mockSession.setupMock(url: testURL, data: testData)
        let cacheManager = NetworkCacheManager.createTestInstance(urlSessionProtocol: mockSession)
        _ = try await cacheManager.fetchData(from: testURL, cachePolicy: .useProtocolCachePolicy)

        let isCached = await cacheManager.isCached(url: testURL)

        XCTAssertTrue(isCached, "Data should be cached")

        let newData = "New response data".data(using: .utf8)!
        await mockSession.setupMock(url: testURL, data: newData)

        let cachedData = try await cacheManager.fetchData(from: testURL, cachePolicy: .returnCacheDataElseLoad)

        // Should return original cached data, not new mock data
        XCTAssertEqual(cachedData, testData, "Should return cached data")
        XCTAssertNotEqual(cachedData, newData, "Should not return new mock data")
    }

    func testCachePolicyReturnCacheDataDontLoad() async {
        let mockSession = MockURLSessionProtocol()
        let cacheManager = NetworkCacheManager.createTestInstance(urlSessionProtocol: mockSession)

        do {
            _ = try await cacheManager.fetchData(from: testURL, cachePolicy: .returnCacheDataDontLoad)
            XCTFail("Should throw error when no cached data available")
        } catch {
            XCTAssertEqual(error, CachingNetworkError.noCachedData, "Should throw noCachedData error")
        }
    }

    func testCachePolicyReloadIgnoringCache() async throws {
        let mockSession = MockURLSessionProtocol()
        await mockSession.setupMock(url: testURL, data: testData)
        let cacheManager = NetworkCacheManager.createTestInstance(urlSessionProtocol: mockSession)
        _ = try await cacheManager.fetchData(from: testURL, cachePolicy: .useProtocolCachePolicy)

        let newData = "New response data".data(using: .utf8)!
        await mockSession.setupMock(url: testURL, data: newData)

        // Fetch ignoring cache
        let freshData = try await cacheManager.fetchData(from: testURL, cachePolicy: .reloadIgnoringLocalCacheData)

        XCTAssertEqual(freshData, newData, "Should return fresh data ignoring cache")
        XCTAssertNotEqual(freshData, testData, "Should not return cached data")
    }

    func testCacheStorage() async throws {
        let mockSession = MockURLSessionProtocol()
        await mockSession.setupMock(url: testURL, data: testData)
        let cacheManager = NetworkCacheManager.createTestInstance(urlSessionProtocol: mockSession)

        _ = try await cacheManager.fetchData(from: testURL)
        _ = try await cacheManager.fetchData(from: testURL)

        let (memory, disk) = await cacheManager.getCacheSize()
        XCTAssertNotEqual(memory, 0)
        XCTAssertNotEqual(disk, 0)

        let isCached = await cacheManager.isCached(url: testURL)
        XCTAssertTrue(isCached, "Data should be cached after fetch")

        let cachedResponse = try await cacheManager.fetchData(from: testURL)
        XCTAssertEqual(cachedResponse, testData, "Cached data should match original")
    }


    // MARK: - Multiple Mock Protocol Test
    func testMultipleMockSetups() async throws {
        let url1 = URL(string: "https://example.com/data1")!
        let url2 = URL(string: "https://example.com/data2")!
        let data1 = "Data 1".data(using: .utf8)!
        let data2 = "Data 2".data(using: .utf8)!

        let mockSession = MockURLSessionProtocol()
        await mockSession.setupMock(url: url1, data: data1)
        await mockSession.setupMock(url: url2, data: data2)
        let cacheManager = NetworkCacheManager.createTestInstance(urlSessionProtocol: mockSession)

        let fetchedData1 = try await cacheManager.fetchData(from: url1)
        let fetchedData2 = try await cacheManager.fetchData(from: url2)

        XCTAssertEqual(fetchedData1, data1, "Should return correct data for URL1")
        XCTAssertEqual(fetchedData2, data2, "Should return correct data for URL2")
        XCTAssertNotEqual(fetchedData1, fetchedData2, "Data should be different for different URLs")
    }

    func testTimeToLive() async throws {
        let url1 = URL(string: "https://example.com/data1")!
        let data1 = "Data 1".data(using: .utf8)!
        let data2 = "Data 2".data(using: .utf8)!

        let mockSession = MockURLSessionProtocol()
        await mockSession.setupMock(url: url1, data: data1)
        let cacheManager = NetworkCacheManager.createTestInstance(
            urlSessionProtocol: mockSession,
            configuration: CacheConfiguration(
                memoryCapacity: 50 * 1024 * 1024,
                diskCapacity: 100 * 1024 * 1024,
                timeToLive: 5,
                acceptableResponseRange: (200...299),
                cacheDirectory: nil
            )
        )

        let fetchedData1 = try await cacheManager.fetchData(from: url1)
        await mockSession.clearMocks()
        await mockSession.setupMock(url: url1, data: data2)

        try await Task.sleep(for: .seconds(6))

        let fetchedData2 = try await cacheManager.fetchData(from: url1)

        XCTAssertNotEqual(fetchedData1, fetchedData2)
    }
}

// MARK: - Test Helper Extensions
extension NetworkCacheManager {
    static func createTestInstance(
        urlSessionProtocol: URLSessionProtocol,
        configuration: CacheConfiguration = .default
    ) -> NetworkCacheManager {
        let testCache = URLCache(
            memoryCapacity: configuration.memoryCapacity,
            diskCapacity: configuration.diskCapacity
        )

        let testManager = NetworkCacheManager(
            configuration: configuration,
            urlCache: testCache,
            urlSession: urlSessionProtocol,
            timeToLiveManager: MockTimeToLiveManager()
        )

        return testManager
    }
}
