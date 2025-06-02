//
//  RecipeClientError.swift
//  RecipeFeature
//
//  Created by RJ Heim on 6/2/25.
//

import Foundation

public enum RecipeClientError: Error {
    case networkError(underlyingError: URLError)
    case invalidResponseType
    case invalidResponse(message: String)
    case decodingError(underlyingError: DecodingError)
}

extension RecipeClientError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .networkError(underlyingError: let underlyingError):
            return "Network error: \(underlyingError.localizedDescription)"

        case .invalidResponseType:
            return "Expected type of HTTPURLResponse"

        case .invalidResponse(message: let message):
            return "Invalid response: \(message)"

        case .decodingError(underlyingError: let underlyingError):
            return "Decoding error: \(underlyingError.localizedDescription)"
        }
    }
}

extension RecipeClientError: CustomNSError {
    public static let errorDomain: String = "RecipeFeature.RecipeClientError"

    public var errorCode: Int {
        switch self {
        case .networkError:
            return 1001
        case .invalidResponseType:
            return 1002
        case .invalidResponse:
            return 1003
        case .decodingError:
            return 1004
        }
    }

    // TODO: Add more details to user info if needed.
    public var errorUserInfo: [String : Any] {
        var info: [String: Any] = [
            NSLocalizedDescriptionKey: self.errorDescription ?? "Unknown error"
        ]
        switch self {
        case .networkError(underlyingError: let underlyingError):
            info["networkUnavailableReason"] = underlyingError.networkUnavailableReason
            info["urlErrorCode"] = underlyingError.code

        case .invalidResponse(message: let message):
            info["invalidResponseMessage"] = message

        case .decodingError(underlyingError: let underlyingError):
            info["decodingErrorCode"] = (underlyingError as NSError).code
            info["decodingErrorMessage"] = underlyingError.localizedDescription

        default:
            break
        }

        return info
    }
}
