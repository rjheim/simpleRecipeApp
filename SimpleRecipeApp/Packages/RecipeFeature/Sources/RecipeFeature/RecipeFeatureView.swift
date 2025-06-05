//
//  RecipeFeatureView.swift
//  RecipeFeature
//
//  Created by RJ Heim on 6/2/25.
//

import SwiftUI

public struct RecipeFeatureView: View {
    @StateObject private var viewModel: RecipeFeatureViewModel

    public init(viewModel: RecipeFeatureViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            recipesView()
                .navigationTitle("Recipes")
                .navigationBarTitleDisplayMode(.large)
        }
    }

    @ViewBuilder
    func recipesView() -> some View {
        if let filteredRecipes = viewModel.filteredRecipes {
            List {
                if filteredRecipes.isEmpty {
                    noRecipeView()
                } else {
                    recipesPerCuisineView(filteredRecipes)
                }
            }
            .listStyle(.insetGrouped)
            .refreshable {
                await viewModel.fetchRecipes(skipCache: true)
            }
            .searchable(text: $viewModel.searchText, prompt: "Search Recipes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker("Cuisine", selection: $viewModel.selectedCuisine) {
                        Text("Select Cuisine")
                            .tag(nil as Cuisine?)
                        ForEach(Cuisine.allCases, id: \.self.rawValue) { cuisine in
                            Text(cuisine.displayName)
                                .tag(cuisine)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        } else if viewModel.hasError {
            recipeFetchErrorView()
        } else {
            LoadingRecipesView()
        }
    }

    @ViewBuilder
    func recipesPerCuisineView(_ filteredRecipes: [Cuisine: [Recipe]]) -> some View {
        ForEach(Cuisine.allCases, id: \.self.rawValue) { cuisine in
            if let recipes = filteredRecipes[cuisine] {
                Section {
                    ForEach(recipes) { recipe in
                        RecipeListItemView(recipe: recipe) { urlString in
                            await viewModel.loadImage(urlString: urlString)
                        }
                    }
                } header: {
                    Text(cuisine.displayName)
                }
            }
        }
    }

    @ViewBuilder
    func noRecipeView() -> some View {
        VStack(spacing: 24) {
            Image(systemName: "fork.knife.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(Color.accentColor)

            Text(viewModel.emptyText)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    @ViewBuilder
    func recipeFetchErrorView() -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(Color.red)

            Text("Oh No! Something went wrong. Please refresh or try again later.")
                .multilineTextAlignment(.center)

            Button("Refresh") {
                Task {
                    await viewModel.fetchRecipes(skipCache: false)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#if DEBUG

import CachingInterfaces
import RecipeInterface

#Preview("Success") {
    RecipeFeatureView(
        viewModel: RecipeFeatureViewModel(client: RecipeClientSuccess.shared) { url in
            try await Task.sleep(for: .seconds(1.5))
            return Image(systemName: "star")
        }
    )
}

#Preview("Empty") {
    RecipeFeatureView(
        viewModel: RecipeFeatureViewModel(client: RecipeClientEmpty.shared) { url in
            try await Task.sleep(for: .seconds(0.5))
            return Image(systemName: "star")
        }
    )
}

#Preview("Failure") {
    RecipeFeatureView(
        viewModel: RecipeFeatureViewModel(client: RecipeClientFailure.shared) { url in
                try await Task.sleep(for: .seconds(0.5))
                return Image(systemName: "star")
            }
    )
}

#endif
