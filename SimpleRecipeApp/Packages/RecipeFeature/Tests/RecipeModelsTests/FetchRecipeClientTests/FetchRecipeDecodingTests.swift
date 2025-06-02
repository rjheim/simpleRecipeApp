//
//  FetchRecipeDecodingTests.swift
//  RecipeFeature
//
//  Created by RJ Heim on 6/2/25.
//

@testable import RecipeModels
import XCTest

final class FetchRecipeDecodingTests: XCTestCase {
    func testSampleConfigurationReturnsValues() async throws {
        guard let testJson = Bundle.module.url(forResource: "testRecipes", withExtension: "json") else {
            XCTFail("Failed to get cat jpg.")
            return
        }

        let jsonData = try Data(contentsOf: testJson)

        let recipes = try JSONDecoder.fetchRecipeClientDecoder.decode(FetchRecipes.self, from: jsonData).recipes

        XCTAssert(!recipes.isEmpty)

        guard let testRecipe = recipes.first(where: { $0.name == "Apam Balik"}) else {
            XCTFail("Could not get Apam Balik recipe")
            return
        }

        XCTAssertEqual(testRecipe.cuisine, "Malaysian")
        XCTAssertEqual(testRecipe.uuid, "0c6ca6e7-e32a-4053-b824-1dbf749910d8")
    }
}

/*
 "cuisine": "Malaysian",
 "name": "Apam Balik",
 "photo_url_large": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
 "photo_url_small": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
 "source_url": "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
 "uuid": "0c6ca6e7-e32a-4053-b824-1dbf749910d8",
 */
