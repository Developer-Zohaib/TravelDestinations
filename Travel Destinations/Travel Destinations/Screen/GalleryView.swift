//
//  GalleryView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI

struct GalleryView: View {
    
    @State private var selectedDestination: URL?
    
    //Dynamic grid layout
    @State private var gridLayout = [GridItem(.flexible())]
    @State private var gridColumn = 3.0
    @State private var viewState: ViewState<[TravelGalleryCollectionModel]> = .idle
    @EnvironmentObject private var firestoreService: FirestoreService
    
    let hapticFeedBack = UINotificationFeedbackGenerator()
    
    func gridSwitch() {
        gridLayout = Array(repeating: GridItem(.flexible()), count: Int(gridColumn) )
    }
    
    var body: some View {
        ZStack {
            content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(MotionAnimationView())
            .task {
                await fetchTravelGalleryCollectionIfNeeded()
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewState {
        case .idle, .loading:
            ProgressView("Loading...")
        case .loaded(let travelGalleryCollection):
            let galleryURLs = travelGalleryCollection.first?.displayGalleryURLs ?? DemoImageProvider.galleryURLs(for: "travel")
            
            ScrollView(.vertical) {
                VStack(alignment: .center, spacing: 30) {
                    if let selectedDestination {
                        RemoteImageView(url: selectedDestination, contentMode: .fill)
                            .frame(width: 300, height: 300)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 8)
                            )
                    } else {
                        ContentUnavailableView("Image Unavailable", systemImage: "photo")
                    }
                    
                    Slider(value: $gridColumn, in: 2...4)
                        .padding(.horizontal)
                        .onChange(of: gridColumn) {
                            withAnimation(.easeIn) {
                                gridSwitch()
                            }
                        }
                    
                    LazyVGrid(columns: gridLayout, alignment: .center, spacing: 10) {
                        ForEach(Array(galleryURLs.enumerated()), id: \.offset) { _, url in
                            RemoteImageView(url: url, contentMode: .fill)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(Color.white, lineWidth: 1)
                                )
                                .frame(width: 150, height: 150)
                                .onTapGesture {
                                    hapticFeedBack.notificationOccurred(.success)
                                    selectedDestination = url
                                }
                        }
                    }
                    .onAppear {
                        gridSwitch()
                        selectedDestination = selectedDestination ?? galleryURLs.first
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 50)
            }
            .refreshable {
                await fetchTravelGalleryCollection(shouldShowLoading: false)
            }
        case .failed(let message):
            ContentUnavailableView {
                Label("Unable to Load Gallery", systemImage: "photo.on.rectangle.angled")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") {
                    Task {
                        await fetchTravelGalleryCollection()
                    }
                }
            }
        }
    }
    
    @MainActor
    private func fetchTravelGalleryCollectionIfNeeded() async {
        guard viewState.shouldPerformInitialLoad else {
            return
        }

        await fetchTravelGalleryCollection()
    }

    @MainActor
    private func fetchTravelGalleryCollection(shouldShowLoading: Bool = true) async {
        let existingGalleryCollection = viewState.loadedValue

        if shouldShowLoading, existingGalleryCollection == nil {
            viewState = .loading
        }
        
        do {
            let galleryCollection: [TravelGalleryCollectionModel] = try await firestoreService.fetchData(collection: "TravelGalleryCollection")
            if selectedDestination == nil || existingGalleryCollection == nil {
                selectedDestination = galleryCollection.first?.displayGalleryURLs.first ?? DemoImageProvider.galleryURLs(for: "travel").first
            }
            viewState = .loaded(galleryCollection)
        } catch {
            if let existingGalleryCollection {
                viewState = .loaded(existingGalleryCollection)
            } else {
                selectedDestination = DemoImageProvider.galleryURLs(for: "travel").first
                viewState = .loaded([])
            }
        }
    }
}
