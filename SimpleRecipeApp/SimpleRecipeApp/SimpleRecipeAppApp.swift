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
    var body: some Scene {
        WindowGroup {
            RecipeFeatureView(
                viewModel: RecipeFeatureViewModel(
                    client: FetchRecipeClient(
                        configuration: FetchRecipeClient.Configuration(
                            url: FetchRecipeClient.sampleURL,
                            sessionType: .caching(NetworkCacheManager.shared)
                        )
                    )
                ) { url in
                    try await NetworkCacheManager.shared.fetchImage(from: url)
                }
            )
        }
    }
}

extension NetworkCacheManager {
    static let shared: NetworkCacheManager = NetworkCacheManager()
}
