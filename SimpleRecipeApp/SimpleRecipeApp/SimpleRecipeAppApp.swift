//
//  SimpleRecipeAppApp.swift
//  SimpleRecipeApp
//
//  Created by RJ Heim on 6/1/25.
//

import Caching
import RecipeFeature
import RecipeModels
import SwiftUI

@main
struct SimpleRecipeAppApp: App {
    let cacheManager = NetworkCacheManager()
    var body: some Scene {
        WindowGroup {
            RecipeFeatureView(
                viewModel: RecipeFeatureViewModel(
                    client: FetchRecipeClient(cacheManager: cacheManager),
                    cacheManager: cacheManager
                )
            )
        }
    }
}
