//
//  URLRequest-CachePolicy+LocalizedDescription.swift
//  Caching
//
//  Created by RJ Heim on 6/1/25.
//

import Foundation

extension URLRequest.CachePolicy {
    var localizedDescription: String {
        switch self {
        case .useProtocolCachePolicy:
            return "Use Protocol Cache Policy"
        case .reloadIgnoringLocalCacheData:
            return "Reload Ignoring Local Cache"
        case .reloadIgnoringLocalAndRemoteCacheData:
            return "Reload Ignoring All Cache"
        case .returnCacheDataElseLoad:
            return "Return Cache Data Else Load"
        case .returnCacheDataDontLoad:
            return "Return Cache Data Don't Load"
        case .reloadRevalidatingCacheData:
            return "Reload Revalidating Cache Data"
        @unknown default:
            return "Unknown Cache Policy"
        }
    }
}
