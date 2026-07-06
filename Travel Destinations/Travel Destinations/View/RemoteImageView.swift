//
//  RemoteImageView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI
import UIKit

@MainActor
final class RemoteImageLoader: ObservableObject {
    enum State {
        case idle
        case loading
        case loaded(UIImage)
        case failed
    }

    @Published private(set) var state: State = .idle

    private let imagePipeline: ImagePipeline
    private var loadedURL: URL?

    init(imagePipeline: ImagePipeline = .shared) {
        self.imagePipeline = imagePipeline
    }

    func load(from url: URL) async {
        if loadedURL == url, case .loaded = state {
            return
        }

        if let cachedImage = await imagePipeline.cachedImage(for: url) {
            loadedURL = url
            state = .loaded(cachedImage)
            return
        }

        state = .loading

        do {
            let image = try await imagePipeline.image(for: url)
            loadedURL = url
            state = .loaded(image)
        } catch is CancellationError {
            state = .idle
        } catch {
            loadedURL = nil
            state = .failed
        }
    }
}

struct RemoteImageView: View {
    let url: URL
    var contentMode: ContentMode = .fill
    var placeholderSystemImage = "photo"

    @StateObject private var loader = RemoteImageLoader()

    var body: some View {
        ZStack {
            switch loader.state {
            case .idle, .loading:
                ProgressView()
            case .loaded(let image):
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            case .failed:
                Image(systemName: placeholderSystemImage)
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
        }
        .task(id: url) {
            await loader.load(from: url)
        }
        .clipped()
    }
}
