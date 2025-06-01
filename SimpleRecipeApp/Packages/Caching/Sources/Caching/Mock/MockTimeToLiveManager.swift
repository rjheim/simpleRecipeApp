//
//  MockTimeToLiveManager.swift
//  Caching
//
//  Created by RJ Heim on 6/1/25.
//

#if DEBUG

import CachingInterfaces
import Foundation

final class MockTimeToLiveManager: TimeToLiveManager {
    private var cache: [URL: Date] = [:]
    private let queue = DispatchQueue(label: "com.app.timeToLiveManager", qos: .utility)

    func getTimeToLive(url: URL) -> Date? {
        return queue.sync { [weak self] in
            return self?.cache[url]
        }
    }

    func saveTimeToLive(url: URL, timeToLive: TimeInterval) {
        queue.sync { [weak self] in
            self?.cache[url] = Date(timeIntervalSinceNow: timeToLive)
        }
    }
}

#endif
