//
//  RemoteImageView.swift
//  RecipeFeature
//
//  Created by RJ Heim on 6/2/25.
//

import SwiftUI

struct RemoteImageView: View {
    @State var image: Image?
    let loadImage: (String?) async -> Image
    let urlString: String?
    let width: CGFloat
    let height: CGFloat

    init(urlString: String?, width: CGFloat, height: CGFloat, loadImage: @escaping (String?) async -> Image) {
        self.loadImage = loadImage
        self.urlString = urlString
        self.width = width
        self.height = height
    }

    init(urlString: String?, squareSize: CGFloat, loadImage: @escaping (String?) async -> Image) {
        self.loadImage = loadImage
        self.urlString = urlString
        self.width = squareSize
        self.height = squareSize
    }

    var body: some View {
        Group {
            if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
            } else {
                ProgressView()
                    .tint(Color.accentColor)
                    .frame(width: width, height: height)
            }
        }
        .task {
            self.image = await loadImage(urlString)
        }
    }
}

#Preview {
    RemoteImageView(
        urlString: "testURL",
        squareSize: 128) { urlString in
            try? await Task.sleep(for: .seconds(2.0))
            return Image(systemName: "star")
        }
}
