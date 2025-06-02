//
//  MockURLSessionProtocol.swift
//  Caching
//
//  Created by RJ Heim on 6/1/25.
//

#if DEBUG

import CachingInterfaces
import Foundation

actor MockURLSessionProtocol: URLSessionProtocol {
    var mockData: [URL: (Data, HTTPURLResponse)] = [:]
    var mockErrors: [URL: Error] = [:]
    var requestDelay: TimeInterval = 0.1

    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
        try await Task.sleep(for: .seconds(requestDelay))

        guard let url = request.url else {
            throw URLError(.badServerResponse)
        }

        if let (data, response) = mockData[url] {
            return (data, response)
        } else if let error = mockErrors[url] {
            throw error
        } else {
            throw URLError(.badServerResponse)
        }
    }

    func setupMock(url: URL, data: Data, statusCode: Int = 200, headers: [String: String]? = nil) {
        let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        )!
        mockData[url] = (data, response)
        mockErrors.removeValue(forKey: url) // Clear any existing error for this URL
    }

    func setupMockError(url: URL, error: Error) {
        mockErrors[url] = error
        mockData.removeValue(forKey: url) // Clear any existing data for this URL
    }

    func clearMocks() {
        mockData.removeAll()
        mockErrors.removeAll()
        requestDelay = 0.1
    }

    func getMockData(for url: URL) -> (Data, HTTPURLResponse)? {
        mockData[url]
    }

    func getMockError(for url: URL) -> Error? {
        mockErrors[url]
    }

    func getRequestDelay() -> TimeInterval {
        requestDelay
    }
}

#endif
