//
//  RecipeListItemView.swift
//  RecipeFeature
//
//  Created by RJ Heim on 6/3/25.
//

import RecipeInterface
import SwiftUI

struct RecipeListItemView: View {
    let recipe: Recipe
    let loadImage: (String?) async -> Image

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(recipe.name)
                    .font(.subheadline)
            }

            Spacer()

            RemoteImageView(urlString: recipe.photoUrlSmall, squareSize: 48) { urlString in
                await loadImage(urlString)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary, lineWidth: 1))
        }
    }
}
