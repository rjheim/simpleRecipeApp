//
//  FetchRecipe.swift
//  RecipeFeature
//
//  Created by RJ Heim on 6/2/25.
//

struct FetchRecipe: Codable, Sendable {
    let cuisine: String
    let name: String
    let photoUrlLarge: String?
    let photoUrlSmall: String?
    let uuid: String
    let sourceUrl: String?
    let youtubeUrl: String?
}
