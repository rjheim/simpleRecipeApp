//
//  FetchRecipeClient.swift
//  RecipeFeature
//
//  Created by RJ Heim on 6/2/25.
//

import CachingInterfaces
import Foundation
import RecipeInterface

public struct FetchRecipeClient: RecipeClient {
    // TODO: This would have any other information that may be need to be injected such as api key, etc.
    public struct Configuration: Sendable {
        let url: URL
        let sessionType: SessionType

        public init(url: URL, sessionType: SessionType) {
            self.url = url
            self.sessionType = sessionType
        }
    }

    public enum SessionType: Sendable {
        case standard(URLSession)
        case caching(CacheManager)
    }

    private let configuration: Configuration

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public func recipes(skipCache: Bool) async throws(RecipeClientError) -> [RecipeInterface.Recipe] {
        let data: Data
        let cachePolicy: NSURLRequest.CachePolicy = skipCache ? .reloadIgnoringLocalCacheData : .useProtocolCachePolicy
        switch configuration.sessionType {
        case .standard(let session):
            do {
                (data, _) = try await session.data(from: configuration.url)
            } catch {
                // TODO: Fix error handling
                if let urlError = error as? URLError {
                    throw RecipeClientError.networkError(underlyingError: urlError)
                } else {
                    throw RecipeClientError.invalidResponse(message: "Unknown error fetching data")
                }
            }

        case .caching(let cacheManager):
            do {
                data = try await cacheManager.fetchData(from: configuration.url, cachePolicy: cachePolicy)
            } catch {
                // TODO: Fix error handling
                switch error {
                case .noCachedData:
                    throw RecipeClientError.invalidResponseType

                case .invalidResponse(statusCode: let statusCode):
                    throw RecipeClientError.invalidResponse(message: "Status code: \(statusCode)")

                case .networkError(underlyingError: let underlyingError):
                    throw RecipeClientError.networkError(underlyingError: underlyingError)

                case .unknownError(underlyingError: let underlyingError):
                    throw RecipeClientError.invalidResponseType

                case .invalidImageData:
                    throw RecipeClientError.invalidResponseType
                }
            }
        }

        let fetchRecipes: FetchRecipes
        do {
            fetchRecipes = try JSONDecoder.fetchRecipeClientDecoder.decode(FetchRecipes.self, from: data)
        } catch {
            // TODO: Fix error handling
            guard let decodingError = error as? DecodingError else {
                throw .invalidResponseType
            }

            throw .decodingError(underlyingError: decodingError)
        }

        return fetchRecipes.recipes.map {
            Recipe(
                cuisine: $0.cuisine,
                name: $0.name,
                photoUrlLarge: $0.photoUrlLarge,
                photoUrlSmall: $0.photoUrlSmall,
                uuid: $0.uuid,
                sourceUrl: $0.sourceUrl,
                youtubeUrl: $0.youtubeUrl
            )
        }
    }
}

extension FetchRecipeClient {
    public static let sampleURL: URL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!

    public static let malformedURL: URL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json")!

    public static let emptyURL: URL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json")!
}

extension JSONDecoder {
    static let fetchRecipeClientDecoder: JSONDecoder = {
        var decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
