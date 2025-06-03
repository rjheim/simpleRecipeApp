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
    // TODO: This would have any other information that may be needed injected. For now, API is just a URL.
    public struct Configuration: Sendable {
        let url: URL
    }
    let configuration: Configuration
    let cacheManager: CacheManager

    // TODO: Let user pick caching policy and configuration
    public init(cacheManager: CacheManager, configuration: Configuration = .sample) {
        self.cacheManager = cacheManager
        self.configuration = configuration
    }

    public func recipes(skipCache: Bool) async throws(RecipeClientError) -> [RecipeInterface.Recipe] {
        let data: Data
        let cachePolicy: NSURLRequest.CachePolicy = skipCache ? .reloadIgnoringLocalCacheData : .useProtocolCachePolicy
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

        let fetchRecipes: FetchRecipes
        do {
            fetchRecipes = try JSONDecoder.fetchRecipeClientDecoder.decode(FetchRecipes.self, from: data)
        } catch {
            guard let decodingError = error as? DecodingError else {
                throw RecipeClientError.networkError(underlyingError: URLError(.unknown))
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

extension FetchRecipeClient.Configuration {
    public static let sample: FetchRecipeClient.Configuration = FetchRecipeClient.Configuration(
        url: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!
    )

    public static let malformed: FetchRecipeClient.Configuration = FetchRecipeClient.Configuration(
        url: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json")!
    )

    public static let empty: FetchRecipeClient.Configuration = FetchRecipeClient.Configuration(
        url: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json")!
    )
}

extension JSONDecoder {
    static let fetchRecipeClientDecoder: JSONDecoder = {
        var decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
