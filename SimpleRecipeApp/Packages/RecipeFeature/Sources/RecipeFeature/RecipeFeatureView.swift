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
        switch viewModel.fetchState {
        case .loading:
            LoadingRecipesView()
                .transition(.opacity)

        case let .error(error):
            recipeFetchErrorView(error: error)

        case let .success(recipes, cuisine, searchText):
            List {
                recipesPerCuisineView(recipes.filter(by: cuisine, searching: searchText))
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
        }
    }

    @ViewBuilder
    func recipesPerCuisineView(_ filteredRecipes: [Cuisine: [Recipe]]) -> some View {
        if filteredRecipes.isEmpty {
            noRecipeView()
        } else {
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
    func recipeFetchErrorView(error: RecipeClientError) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(Color.red)

            Text("Oh No! Something went wrong. Please refresh or try again later.")
                .multilineTextAlignment(.center)

            // TODO: Probably wouldn't present this to the user, but you could have a more friendly error message that the use could use with customer support here.
            if let description = error.errorDescription {
                Text("Error Description: \(description)")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
            }

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
            try await Task.sleep(for: .seconds(0.2))
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
