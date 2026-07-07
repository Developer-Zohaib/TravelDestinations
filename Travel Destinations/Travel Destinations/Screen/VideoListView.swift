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
	                    .toolbar(.hidden, for: .navigationBar)
	                    .background(AppTheme.appGradient.ignoresSafeArea())
	                    .navigationDestination(for: Video.self) { video in
	                        VideoPlayerView(videoData: video)
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
            AppLoadingView(
                title: "Loading Travel Watch",
                message: "Getting the latest destination videos"
            )
        case .loaded(let travelVideoCollection):
            if travelVideoCollection.isEmpty {
                ContentUnavailableView(
                    "No Videos",
                    systemImage: "play.rectangle",
                    description: Text("Pull to refresh or check your data source.")
                )
            } else {
                VStack(spacing: 0) {
                    watchHeader
                        .padding(.horizontal, 18)
                        .padding(.top, 24)
                        .padding(.bottom, 12)

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
                        .scrollContentBackground(.hidden)
                        .background(AppTheme.appGradient)
                        .tint(.gray)
                }
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

    private var watchHeader: some View {
        AppHeaderView(title: "Travel", highlightedTitle: " Watch")
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
