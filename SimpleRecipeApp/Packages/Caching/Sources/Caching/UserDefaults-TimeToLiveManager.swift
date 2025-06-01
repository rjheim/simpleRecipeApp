//
//  UserDefaults-TimeToLiveManager.swift
//  Caching
//
//  Created by RJ Heim on 6/1/25.
//

import CachingInterfaces
import Foundation

extension UserDefaults: TimeToLiveManager {
    public func getTimeToLive(url: URL) -> Date? {
        let key: String = .userDefaultsSuiteName + url.absoluteString

        return self.object(forKey: key) as? Date
    }

    public func saveTimeToLive(url: URL, timeToLive: TimeInterval) {
        let key: String = .userDefaultsSuiteName + url.absoluteString

        self.set(Date(timeIntervalSinceNow: timeToLive), forKey: key)
    }

    static func timeToLiveManager(suiteName: String = .userDefaultsSuiteName) -> TimeToLiveManager {
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            assertionFailure("Could not load user defaults for time to live manager.")
            return UserDefaults.standard
        }

        return defaults
    }
}

private extension String {
    static let userDefaultsSuiteName: String = "rjheim.SimpleRecipeApp.cacheHelper"
}
