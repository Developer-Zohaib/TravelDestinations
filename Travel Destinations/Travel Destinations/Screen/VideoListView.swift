//
//  VideoListView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI

struct VideoListView: View {
    
    @EnvironmentObject private var firestoreService: FirestoreService
    @State private var viewState: ViewState<[Video]> = .idle
    let hapticFeedBack = UINotificationFeedbackGenerator()

    var body: some View {
            NavigationStack {
                content
                    .navigationTitle("Videos")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(for: Video.self) { video in
                        VideoPlayerView(videoData: video)
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                hapticFeedBack.notificationOccurred(.success)
                            }, label: {
                                Image(systemName: "arrow.2.squarepath")
                            })
                        }
                    }
                    .task {
                        await fetchTravelVideoCollectionIfNeeded()
                    }
            }
        }
    
    @ViewBuilder
    private var content: some View {
        switch viewState {
        case .idle, .loading:
            ProgressView("Loading...")
        case .loaded(let travelVideoCollection):
            if travelVideoCollection.isEmpty {
                ContentUnavailableView(
                    "No Videos",
                    systemImage: "play.rectangle",
                    description: Text("Pull to refresh or check your data source.")
                )
            } else {
                List {
                    ForEach(travelVideoCollection, id: \.id) { video in
                            NavigationLink(value: video) {
                                VideoListItemView(video: video)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                    .refreshable {
                        await fetchTravelVideoCollection(shouldShowLoading: false)
                    }
                    .listStyle(.insetGrouped)
                    .tint(.gray)
            }
        case .failed(let message):
            ContentUnavailableView {
                Label("Unable to Load Videos", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") {
                    Task {
                        await fetchTravelVideoCollection()
                    }
                }
            }
        }
    }
    
    @MainActor
    private func fetchTravelVideoCollectionIfNeeded() async {
        guard viewState.shouldPerformInitialLoad else {
            return
        }

        await fetchTravelVideoCollection()
    }

    @MainActor
    private func fetchTravelVideoCollection(shouldShowLoading: Bool = true) async {
        let existingVideos = viewState.loadedValue

        if shouldShowLoading, existingVideos == nil {
            viewState = .loading
        }
        
        do {
            let videos: [Video] = try await firestoreService.fetchData(collection: "TravelVideoCollection")
            viewState = .loaded(videos)
        } catch {
            if let existingVideos {
                viewState = .loaded(existingVideos)
            } else {
                viewState = .failed(error.localizedDescription)
            }
        }
    }
}
