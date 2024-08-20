//
//  VideoListView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI

struct VideoListView: View {
    
    @EnvironmentObject private var firestoreService: FirestoreService
    @State private var travelVideoCollection: [Video] = []
    let hapticFeedBack = UINotificationFeedbackGenerator()
    @State private var isLoading: Bool = true

    var body: some View {
            NavigationSplitView {
                ZStack {
                    List {
                        ForEach(travelVideoCollection) { video in
                            NavigationLink(destination: VideoPlayerView(videoData: video)) {
                                VideoListItemView(video: video)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                    .refreshable {
                        fetchTravelVideoCollection()
                    }
                    .listStyle(.insetGrouped)
                    .navigationTitle("Videos")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                // videos.shuffle()
                                hapticFeedBack.notificationOccurred(.success)
                            }, label: {
                                Image(systemName: "arrow.2.squarepath")
                            })
                        }
                    }
                    .tint(.gray)
                    
                    if isLoading {
                        ProgressView("Loading...")
                            .onAppear {
                                fetchTravelVideoCollection()
                            }
                    }
                }
            } detail: {
                EmptyView()
            }
        }
    
    private func fetchTravelVideoCollection() {
        isLoading = true
        firestoreService.fetchData(collection: "TravelVideoCollection") { (result: Result<[Video], Error>) in
            isLoading = false
            switch result {
            case .success(let travelVideoCollection):
                self.travelVideoCollection = travelVideoCollection
                
            case .failure(let error):
                print("Error fetching documents: \(error.localizedDescription)")
            }
        }
    }
}
