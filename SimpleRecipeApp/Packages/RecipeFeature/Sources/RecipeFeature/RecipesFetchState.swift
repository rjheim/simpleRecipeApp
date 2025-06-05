//
//  RecipesFetchState.swift
//  RecipeFeature
//
//  Created by RJ Heim on 6/2/25.
//

import RecipeInterface

enum RecipesFetchState: Sendable {
    case loading
    case error(RecipeClientError)
    case success([Recipe], Cuisine?, String)
}

extension RecipesFetchState: Equatable  {
    static func == (lhs: RecipesFetchState, rhs: RecipesFetchState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case(.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError

        case let (.success(lhsRecipes, lhsCuisine, lhsSearch), .success(rhsRecipes, rhsCuisine, rhsSearch)):
            return lhsRecipes == rhsRecipes && lhsCuisine == rhsCuisine && lhsSearch == rhsSearch

        default:
            return false
        }
    }
}
