//
//  URLSessionProtocol.swift
//  Caching
//
//  Created by RJ Heim on 6/1/25.
//

import Foundation

public protocol URLSessionProtocol: Sendable {
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol { }
