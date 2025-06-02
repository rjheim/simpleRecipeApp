//
//  FetchRecipeClient.swift
//  RecipeFeature
//
//  Created by RJ Heim on 6/2/25.
//

import Foundation
import RecipeInterface

public struct FetchRecipeClient: RecipeClient {
    // TODO: This would have any other information that may be needed injected. For now, API is just a URL.
    public struct Configuration: Sendable {
        let url: URL
    }
    let configuration: Configuration
    let session: URLSession

    public init(session: URLSession, configuration: Configuration = .sample) {
        self.session = session
        self.configuration = configuration
    }

    public func recipes() async throws(RecipeInterface.RecipeClientError) -> [RecipeInterface.Recipe] {
        let request = URLRequest(url: configuration.url)
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw RecipeClientError.invalidResponseType
            }

            switch httpResponse.statusCode {
            case (200...299):
                break

            default:
                throw RecipeClientError.invalidResponse(message: "Received invalid status code: \(httpResponse.statusCode)")
            }
        } catch {
            guard let urlError = error as? URLError else {
                throw RecipeClientError.networkError(underlyingError: URLError(.unknown))
            }

            throw RecipeClientError.networkError(underlyingError: urlError)
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
