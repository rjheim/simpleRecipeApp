//
//  LoadingRecipesView.swift
//  RecipeFeature
//
//  Created by RJ Heim on 6/3/25.
//

import SwiftUI

struct LoadingRecipesView: View {
    @State private var isSpinning: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "spoon.serving")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(Color.accentColor)
                .rotationEffect(.degrees(isSpinning ? 0 : 360))
                .animation(
                    .spring(
                        response: 0.95,
                        dampingFraction: 0.4
                    )
                    .repeatForever(autoreverses: false),
                    value: isSpinning
                )

            Text("Loading Recipes...")
                .multilineTextAlignment(.center)
        }
        .padding()
        .onAppear {
            isSpinning = true
        }
    }
}

#Preview {
    LoadingRecipesView()
}
