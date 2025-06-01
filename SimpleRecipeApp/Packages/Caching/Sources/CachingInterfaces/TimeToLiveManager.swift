//
//  TimeToLiveManager.swift
//  Caching
//
//  Created by RJ Heim on 6/1/25.
//

import Foundation

public protocol TimeToLiveManager {
    func getTimeToLive(url: URL) -> Date?
    func saveTimeToLive(url: URL, timeToLive: TimeInterval)
}
