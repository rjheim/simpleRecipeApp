//
//  YouTubePlayerView.swift
//  RecipeFeature
//
//  Created by RJ Heim on 6/5/25.
//

import SwiftUI
import WebKit

struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true

        let dataStore = WKWebsiteDataStore.nonPersistent()
        configuration.websiteDataStore = dataStore

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: "https://www.youtube.com/embed/\(videoID)?playsinline=1&autoplay=0&rel=0&showinfo=0&controls=1") else {
            return
        }

        let request = URLRequest(url: url)
        uiView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Optional: Handle navigation completion
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Failed to load YouTube video: \(error.localizedDescription)")
        }
    }
}

extension YouTubePlayerView {
    init(youtubeURL: String) {
        // Extract video ID from various YouTube URL formats
        if let videoID = Self.extractVideoID(from: youtubeURL) {
            self.videoID = videoID
        } else {
            self.videoID = ""
        }
    }

    // TODO: Add testing
    static func extractVideoID(from urlString: String) -> String? {
        guard let url = URL(string: urlString) else { return nil }

        // Handle youtu.be format
        if url.host == "youtu.be" {
            return String(url.pathComponents.last ?? "")
        }

        // Handle youtube.com format
        if url.host?.contains("youtube.com") == true {
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
            return queryItems?.first(where: { $0.name == "v" })?.value
        }

        return nil
    }
}
