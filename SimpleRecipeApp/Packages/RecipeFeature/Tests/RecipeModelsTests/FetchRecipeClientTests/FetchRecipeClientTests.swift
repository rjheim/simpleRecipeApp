//
//  FetchRecipeClientTests.swift
//  RecipeFeature
//
//  Created by RJ Heim on 6/2/25.
//

@testable import RecipeModels
import XCTest

final class FetchRecipeClientTests: XCTestCase {
    func testSampleConfigurationReturnsValues() async throws {
        let client = FetchRecipeClient(session: .shared)
        let results = try await client.recipes()

        XCTAssert(!results.isEmpty)
    }

    func testMalformedConfigurationThrowsError() async throws {
        let client = FetchRecipeClient(session: .shared, configuration: .malformed)
        do {
            let results = try await client.recipes()
        } catch {
            XCTAssertEqual(error.errorCode, 1004)
        }
    }

    func testEmptyConfigurationReturnsNoValues() async throws {
        let client = FetchRecipeClient(session: .shared, configuration: .empty)
        let results = try await client.recipes()

        XCTAssert(results.isEmpty)
    }
}
