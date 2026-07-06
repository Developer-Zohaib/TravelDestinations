//
//  ContentView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI

struct ContentView: View {
    
    @State private var isGridViewActive = false
    
    // Dynamic grid layout
    @State private var gridLayout = [GridItem(.flexible())]
    @State private var gridColumn = 2
    @State private var toolbarIcon = "square.grid.2x2"
    @State private var viewState: ViewState<[TravelDestination]> = .idle
    @EnvironmentObject private var firestoreService: FirestoreService
    
    let hapticFeedBack = UINotificationFeedbackGenerator()
    
    func gridSwitch() {
        gridLayout = Array(repeating: GridItem(.flexible()), count: (gridLayout.count % 3) + 1)
        gridColumn = gridLayout.count
        
        switch gridColumn {
            
        case 1:
            toolbarIcon = "square.grid.2x2"
            
        case 2:
            toolbarIcon = "square.grid.3x2"
            
        case 3:
            toolbarIcon = "rectangle.grid.1x2"
            
        default:
            toolbarIcon = "square.grid.2x2"
        }
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Travel Destinations")
                .navigationBarTitleDisplayMode(.large)
                .navigationDestination(for: TravelDestination.self) { destination in
                    TravelDestinationDetailView(travelDestination: destination)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 16) {
                            Button(action: {
                                withoutContentAnimation {
                                    isGridViewActive = false
                                }
                                hapticFeedBack.notificationOccurred(.success)
                            }, label: {
                                Image(systemName: "square.fill.text.grid.1x2")
                                    .font(.title2)
                                    .foregroundColor(isGridViewActive ? .primary : .accentColor)
                            })
                            
                            Button(action: {
                                hapticFeedBack.notificationOccurred(.success)

                                if isGridViewActive {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        gridSwitch()
                                    }
                                } else {
                                    withoutContentAnimation {
                                        isGridViewActive = true
                                    }
                                }
                            }, label: {
                                Image(systemName: toolbarIcon)
                                    .font(.title2)
                                    .foregroundColor(isGridViewActive ? .accentColor : .primary)
                            })
                        }
                    }
                }
                .task {
                    await fetchTravelDestinationsIfNeeded()
                }
        }
    }

    private func withoutContentAnimation(_ updates: () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            updates()
        }
    }

    private func prefetchDestinationImages(for destinations: [TravelDestination]) {
        let urls = destinations.compactMap(\.displayImageURL)

        Task(priority: .utility) {
            await ImagePipeline.shared.prefetch(urls)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewState {
        case .idle, .loading:
            ProgressView("Loading...")
        case .loaded(let travelDestinations):
            if travelDestinations.isEmpty {
                ContentUnavailableView(
                    "No Destinations",
                    systemImage: "airplane.departure",
                    description: Text("Pull to refresh or check your data source.")
                )
            } else if !isGridViewActive {
                ListView(travelDestinations: travelDestinations)
                    .refreshable {
                        await fetchTravelDestinations(shouldShowLoading: false)
                    }
            } else {
                GridView(travelDestinations: travelDestinations, gridLayout: gridLayout)
                    .refreshable {
                        await fetchTravelDestinations(shouldShowLoading: false)
                    }
            }
        case .failed(let message):
            ContentUnavailableView {
                Label("Unable to Load Destinations", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") {
                    Task {
                        await fetchTravelDestinations()
                    }
                }
            }
        }
    }

    @MainActor
    private func fetchTravelDestinationsIfNeeded() async {
        guard viewState.shouldPerformInitialLoad else {
            return
        }

        await fetchTravelDestinations()
    }

    @MainActor
    private func fetchTravelDestinations(shouldShowLoading: Bool = true) async {
        let existingDestinations = viewState.loadedValue

        if shouldShowLoading, existingDestinations == nil {
            viewState = .loading
        }
        
        do {
            let destinations: [TravelDestination] = try await firestoreService.fetchData(collection: "TravelDestinations")
            viewState = .loaded(destinations)
            prefetchDestinationImages(for: destinations)
        } catch {
            if let existingDestinations {
                viewState = .loaded(existingDestinations)
            } else {
                viewState = .failed(error.localizedDescription)
            }
        }
    }
}

struct ListView: View {
    let travelDestinations: [TravelDestination]
    
    var body: some View {
        List {
            ForEach(travelDestinations, id: \.id) { destination in
                NavigationLink(value: destination) {
                    TravelDestinationListItemView(travelDestination: destination)
                }
                .listRowBackground(Color.clear)
            }
        }
        .tint(.gray)
    }
}

struct GridView: View {
    let travelDestinations: [TravelDestination]
    let gridLayout: [GridItem]
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: gridLayout, alignment: .center, spacing: 10) {
                ForEach(travelDestinations, id: \.id) { destination in
                    NavigationLink(value: destination) {
                        TravelDestinationGridItemView(travelDestination: destination)
                    }
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
}
