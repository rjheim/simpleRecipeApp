//
//  Recipe.swift
//  RecipeFeature
//
//  Created by RJ Heim on 6/2/25.
//

public struct Recipe: Identifiable, Equatable, Hashable, Sendable {
    public var id: String {
        uuid
    }
    public let cuisine: Cuisine
    public let name: String
    public let photoUrlLarge: String?
    public let photoUrlSmall: String?
    public let uuid: String
    public let sourceUrl: String?
    public let youtubeUrl: String?

    public init(
        cuisine: String,
        name: String,
        photoUrlLarge: String?,
        photoUrlSmall: String?,
        uuid: String,
        sourceUrl: String?,
        youtubeUrl: String?
    ) {
        self.cuisine = Cuisine(rawValue: cuisine) ?? .other(cuisine)
        self.name = name
        self.photoUrlLarge = photoUrlLarge
        self.photoUrlSmall = photoUrlSmall
        self.uuid = uuid
        self.sourceUrl = sourceUrl
        self.youtubeUrl = youtubeUrl
    }
}
