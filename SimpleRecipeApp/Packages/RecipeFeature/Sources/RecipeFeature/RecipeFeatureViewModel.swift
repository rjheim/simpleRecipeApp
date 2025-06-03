//
//  RecipeFeatureViewModel.swift
//  RecipeFeature
//
//  Created by RJ Heim on 6/2/25.
//

import CachingInterfaces
import RecipeInterface
import SwiftUI

@MainActor
public final class RecipeFeatureViewModel: ObservableObject {
    @Published var filteredRecipes: [Cuisine: [Recipe]]?

    private var recipes: [Recipe] = [] {
        didSet {
            self.filteredRecipes = recipes.filter(by: self.selectedCuisine, searching: self.searchText)
        }
    }
    @Published var selectedCuisine: Cuisine? {
        didSet {
            self.filteredRecipes = recipes.filter(by: self.selectedCuisine, searching: self.searchText)
        }
    }
    @Published var searchText: String = "" {
        didSet {
            self.filteredRecipes = recipes.filter(by: self.selectedCuisine, searching: self.searchText)
        }
    }
    @Published var hasError: Bool = false
    var emptyText: String {
        let isSelectedCuisineEmpty = self.selectedCuisine == nil
        let isSearchTextEmpty = self.searchText.isEmpty

        switch (isSelectedCuisineEmpty, isSearchTextEmpty) {
        case (true, true):
            return "Oh No! There are no recipes available right now. Please pull to refresh or try again later."

        case (true, false):
            return "Oh No! There are no recipes matching your search of \(self.searchText)."

        case (false, true):
            return "Oh No! There are no recipes for \(self.selectedCuisine?.displayName ?? "Other") cuisine."

        case (false, false):
            return "Oh No! There are no recipes for \(self.selectedCuisine?.displayName ?? "Other") cuisine matching your search of \(self.searchText)."
        }

    }
    private var lastForceRefreshed: Date = .distantPast

    private let client: RecipeClient
    private let cacheManager: CacheManager

    public init(client: RecipeClient, cacheManager: CacheManager) {
        self.client = client
        self.cacheManager = cacheManager

        Task {
            await fetchRecipes(skipCache: false)
        }
    }

    func fetchRecipes(skipCache: Bool) async {
        self.hasError = false

        // If refresh has occurred within the last 15 seconds, skip.
        if Date().timeIntervalSince(lastForceRefreshed) < 15 {
            return
        }

        do {
            self.recipes = try await client.recipes(skipCache: skipCache)
            // Only set last force refresh date if we skipped the cache.
            if skipCache {
                self.lastForceRefreshed = Date()
            }
        } catch {
            self.hasError = true
        }
    }

    // TODO: Could throw error and handle in view. Let view decide placeholder.
    func loadImage(urlString: String?) async -> Image {
        guard let urlString, let url = URL(string: urlString) else {
            return Image("photo.trianglebadge.exclamationmark.fill")
        }
        do {
            let detachedTask = Task.detached {
                return try await self.cacheManager.fetchImage(from: url, cachePolicy: .useProtocolCachePolicy)
            }
            return try await detachedTask.value
        } catch {
            return Image("photo.trianglebadge.exclamationmark.fill")
        }
    }
}
// TODO: Add testing
extension Array where Element == Recipe {
    func filter(by cuisine: Cuisine?, searching: String) -> [Cuisine: [Recipe]] {
        let searchFilteredRecipes: [Recipe]
        if searching.isEmpty {
            searchFilteredRecipes = self
        } else {
            searchFilteredRecipes = self.filter { $0.name.localizedCaseInsensitiveContains(searching) }
        }

        if let cuisine {
            return Dictionary(grouping: searchFilteredRecipes, by: { $0.cuisine })
                .filter { key, _ in
                    key == cuisine
                }
        } else {
            return Dictionary(grouping: searchFilteredRecipes, by: { $0.cuisine })
        }
    }
}
