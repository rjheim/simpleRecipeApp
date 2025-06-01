//
//  CacheConfiguration.swift
//  Caching
//
//  Created by RJ Heim on 6/1/25.
//

import Foundation
import SwiftUI

public struct CacheConfiguration: Sendable {
    public let memoryCapacity: Int
    public let diskCapacity: Int
    public let timeToLive: TimeInterval
    public let acceptableResponseRange: ClosedRange<Int>
    public let cacheDirectory: String?

    public static let `default` = CacheConfiguration(
        memoryCapacity: 50 * 1024 * 1024,       // 50 MB
        diskCapacity: 200 * 1024 * 1024,        // 200 MB
        timeToLive: 60 * 60,                    // One Hour
        acceptableResponseRange: (200...299),   // All 200's
        cacheDirectory: nil
    )

    public static let aggressive = CacheConfiguration(
        memoryCapacity: 100 * 1024 * 1024,      // 100 MB
        diskCapacity: 500 * 1024 * 1024,        // 500 MB
        timeToLive: 60 * 60 * 2,                // Two Hours
        acceptableResponseRange: (200...299),   // All 200's
        cacheDirectory: nil
    )

    public init(
        memoryCapacity: Int,
        diskCapacity: Int,
        timeToLive: TimeInterval,
        acceptableResponseRange: ClosedRange<Int>,
        cacheDirectory: String?
    ) {
        self.memoryCapacity = memoryCapacity
        self.diskCapacity = diskCapacity
        self.timeToLive = timeToLive
        self.acceptableResponseRange = acceptableResponseRange
        self.cacheDirectory = cacheDirectory
    }
}
