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
