//
//  RecipeClient.swift
//  RecipeFeature
//
//  Created by RJ Heim on 6/2/25.
//

public protocol RecipeClient: Sendable {
    func recipes(skipCache: Bool) async throws(RecipeClientError) -> [Recipe]
}

public struct RecipeClientSuccess: RecipeClient {
    public static let shared: RecipeClientSuccess = RecipeClientSuccess()

    public func recipes(skipCache: Bool) async throws(RecipeClientError) -> [Recipe] {
        do {
            try await Task.sleep(for: .seconds(3))
        } catch {
            throw RecipeClientError.invalidResponseType
        }

        return .sample
    }
}

public struct RecipeClientFailure: RecipeClient {
    public static let shared: RecipeClientFailure = RecipeClientFailure()

    public func recipes(skipCache: Bool) async throws(RecipeClientError) -> [Recipe] {
        do {
            try await Task.sleep(for: .seconds(2))
        } catch {
            throw .invalidResponseType
        }

        throw .invalidResponseType
    }
}

public struct RecipeClientEmpty: RecipeClient {
    public static let shared: RecipeClientEmpty = RecipeClientEmpty()

    public func recipes(skipCache: Bool) async throws(RecipeClientError) -> [Recipe] {
        do {
            try await Task.sleep(for: .seconds(0.5))
        } catch {
            throw RecipeClientError.invalidResponseType
        }

        return []
    }
}

extension Array where Element == Recipe {
    public static let sample: Self = {
        [
            Recipe(
                cuisine: "Malaysian",
                name: "Apam Balik",
                photoUrlLarge: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
                photoUrlSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
                uuid: "0c6ca6e7-e32a-4053-b824-1dbf749910d8",
                sourceUrl: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
                youtubeUrl: "https://www.youtube.com/watch?v=6R8ffRRJcrg"
            ),
            Recipe(
                cuisine: "British",
                name: "Apple & Blackberry Crumble",
                photoUrlLarge: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/large.jpg",
                photoUrlSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/small.jpg",
                uuid: "599344f4-3c5c-4cca-b914-2210e3b3312f",
                sourceUrl: "https://www.bbcgoodfood.com/recipes/778642/apple-and-blackberry-crumble",
                youtubeUrl: "https://www.youtube.com/watch?v=4vhcOwVBDO4"
            ),
            Recipe(
                cuisine: "British",
                name: "Apple Frangipan Tart",
                photoUrlLarge: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/7276e9f9-02a2-47a0-8d70-d91bdb149e9e/large.jpg",
                photoUrlSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/7276e9f9-02a2-47a0-8d70-d91bdb149e9e/small.jpg",
                uuid: "74f6d4eb-da50-4901-94d1-deae2d8af1d1",
                sourceUrl: nil,
                youtubeUrl: "https://www.youtube.com/watch?v=rp8Slv4INLk"
            ),
            Recipe(
                cuisine: "British",
                name: "Bakewell Tart",
                photoUrlLarge: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/dd936646-8100-4a1c-b5ce-5f97adf30a42/large.jpg",
                photoUrlSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/dd936646-8100-4a1c-b5ce-5f97adf30a42/small.jpg",
                uuid: "eed6005f-f8c8-451f-98d0-4088e2b40eb6",
                sourceUrl: nil,
                youtubeUrl: "https://www.youtube.com/watch?v=1ahpSTf_Pvk"
            )
        ]
    }()
}

extension Recipe {
    public static let sampleRecipe: Recipe = Recipe(
        cuisine: "Malaysian",
        name: "Apam Balik",
        photoUrlLarge: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
        photoUrlSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
        uuid: "0c6ca6e7-e32a-4053-b824-1dbf749910d8",
        sourceUrl: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
        youtubeUrl: "https://www.youtube.com/watch?v=6R8ffRRJcrg"
    )
}
