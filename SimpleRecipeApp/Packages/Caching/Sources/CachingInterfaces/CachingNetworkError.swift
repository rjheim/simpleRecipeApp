//
//  CachingNetworkError.swift
//  Caching
//
//  Created by RJ Heim on 6/1/25.
//

import Foundation

public enum CachingNetworkError: Error {
    case noCachedData
    case invalidResponse(statusCode: Int)
    case networkError(underlyingError: URLError)
    case unknownError(underlyingError: Error)
    case invalidImageData
}

extension CachingNetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noCachedData:
            return "No cached data available"

        case .invalidResponse(let statusCode):
            return "Received invalid response with statusCode: \(statusCode)"

        case .networkError(let urlError):
            return "Invalid response received with URLError: \(urlError.localizedDescription)"

        case .unknownError(let error):
            return "Failed with unknown error: \(error.localizedDescription)"

        case .invalidImageData:
            return "Unable to create image from data"
        }
    }
}

extension CachingNetworkError: CustomNSError {
    public static var errorDomain: String {
        return "CachingNetworkError"
    }

    public var errorCode: Int {
        switch self {
        case .invalidResponse(statusCode: let statusCode):
            return statusCode

        case .networkError:
            return 1

        case .noCachedData:
            return 2

        case .invalidImageData:
            return 2

        case .unknownError:
            return -1
        }
    }

    public var errorUserInfo: [String : Any] {
        var info: [String: Any] =  [ NSLocalizedDescriptionKey : errorDescription ?? "Unknown error" ]
        switch self {
        case .networkError(underlyingError: let underlyingError):
            info["urlErrorCode"] = underlyingError.code
            info["urlErrorLocalizedDescription"] = underlyingError.localizedDescription
            info["networkUnavailableReason"] = underlyingError.networkUnavailableReason

        default:
            break
        }

        return info
    }
}

extension CachingNetworkError: Equatable {
    public static func == (lhs: CachingNetworkError, rhs: CachingNetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.noCachedData, .noCachedData):
            return true

        case (.invalidResponse(let statusCodeLHS), .invalidResponse(statusCode: let statusCodeRHS)):
            return statusCodeLHS == statusCodeRHS

        case (.networkError(let errorLHS), .networkError(underlyingError: let errorRHS)):
            return errorLHS.code == errorRHS.code

        case (.unknownError(underlyingError: let errorLHS), .unknownError(underlyingError: let errorRHS)):
            return errorLHS as NSError == errorRHS as NSError

        case (.invalidImageData, .invalidImageData):
            return true

        default:
            return false
        }
    }
}
