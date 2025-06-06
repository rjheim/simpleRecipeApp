//
//  RecipeDetailView.swift
//  RecipeFeature
//
//  Created by RJ Heim on 6/5/25.
//

import RecipeInterface
import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    let loadImage: (String?) async -> Image

    @Environment(\.colorScheme) var colorScheme
    @State private var scrollOffset: CGFloat = 0
    @State private var headerImage: Image?
    @State private var backgroundImage: Image?

    var body: some View {
        GeometryReader { geo in
            ScrollView(.vertical, showsIndicators: false) {
                ZStack(alignment: .topLeading) {
                    RemoteImageView(urlString: recipe.photoUrlLarge) { urlString in
                        await loadImage(urlString)
                    }
                    .frame(
                        maxWidth: geo.size.width > geo.size.height ? geo.size.height : nil,
                        minHeight: geo.size.width > geo.size.height ? geo.size.height : geo.size.width,
                        maxHeight: geo.size.width > geo.size.height ? geo.size.height : nil
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 8, x: 0, y: 5)

                    Text(recipe.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .padding(8)
                        .background(Color.secondary.opacity(0.8))
                        .cornerRadius(8)
                        .padding([.leading, .top], 4)
                }
                .padding(.bottom, 16)

                VStack {
                    LabeledContent("Cuisine", value: recipe.cuisine.displayName)
                        .font(.headline)
                        .padding(.horizontal)

                    if let youtubeUrl = recipe.youtubeUrl {
                        YouTubePlayerView(youtubeURL: youtubeUrl)
                            .frame(height: geo.size.width > geo.size.height ? geo.size.width * 0.5625 : geo.size.height * 0.3)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                            .padding()
                    }

                    if let sourceURLString = recipe.sourceUrl, let sourceUrl = URL(string: sourceURLString) {
                        ShareLink("Recipe Source", item: sourceUrl, subject: Text("\(recipe.name)"))
                    }
                }
            }
        }
    }
}

#if DEBUG

#Preview {
    RecipeDetailView(recipe: Recipe.sampleRecipe) { urlString in
        try? await Task.sleep(for: .seconds(2.0))
        return Image(systemName: "mountain.2.fill")
    }
}

#endif
