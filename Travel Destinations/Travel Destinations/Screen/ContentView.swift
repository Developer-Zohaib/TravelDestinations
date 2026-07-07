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

    private var browseLayoutIcon: String {
        isGridViewActive ? toolbarIcon : "rectangle.grid.1x2"
    }

    private var browseLayoutTint: Color {
        isGridViewActive ? AppTheme.accent : AppTheme.secondaryText
    }

    private func setGridColumn(_ count: Int) {
        gridColumn = count
        gridLayout = Array(repeating: GridItem(.flexible()), count: count)

        switch count {
        case 1:
            toolbarIcon = "rectangle.grid.1x2"
        case 2:
            toolbarIcon = "square.grid.2x2"
        case 3:
            toolbarIcon = "square.grid.3x2"
        default:
            toolbarIcon = "square.grid.2x2"
        }
    }

    func gridSwitch() {
        setGridColumn((gridLayout.count % 3) + 1)
    }

    private func advanceBrowseLayout() {
        hapticFeedBack.notificationOccurred(.success)

        if !isGridViewActive {
            withAnimation(.easeInOut(duration: 0.2)) {
                setGridColumn(1)
                isGridViewActive = true
            }
        } else if gridColumn >= 3 {
            withAnimation(.easeInOut(duration: 0.2)) {
                isGridViewActive = false
            }
        } else {
            withAnimation(.easeInOut(duration: 0.2)) {
                setGridColumn(gridColumn + 1)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            content
                .toolbar(.hidden, for: .navigationBar)
                .background(AppTheme.appGradient.ignoresSafeArea())
                .navigationDestination(for: TravelDestination.self) { destination in
                    TravelDestinationDetailView(travelDestination: destination)
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
            AppLoadingView(
                title: "Preparing Destinations",
                message: "Curating your travel feed"
            )
        case .loaded(let travelDestinations):
            if travelDestinations.isEmpty {
                ContentUnavailableView(
                    "No Destinations",
                    systemImage: "airplane.departure",
                    description: Text("Pull to refresh or check your data source.")
                )
            } else {
                browseContent(for: travelDestinations)
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

    private var browseHeader: some View {
        AppHeaderView(title: "Travel", highlightedTitle: " Destinations") {
            Button {
                advanceBrowseLayout()
            } label: {
                Image(systemName: browseLayoutIcon)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(browseLayoutTint)
                    .frame(width: 52, height: 52)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.softBorder))
            }
            .buttonStyle(.plain)
        }
    }

    private func browseContent(for travelDestinations: [TravelDestination]) -> some View {
        VStack(spacing: 0) {
            browseHeader
                .padding(.horizontal, 18)
                .padding(.top, 24)
                .padding(.bottom, 12)

            ZStack {
                if isGridViewActive {
                    GridView(travelDestinations: travelDestinations, gridLayout: gridLayout)
                        .id("grid-\(gridColumn)")
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                } else {
                    ListView(travelDestinations: travelDestinations)
                        .id("list")
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
            .animation(.easeInOut(duration: 0.22), value: isGridViewActive)
            .animation(.easeInOut(duration: 0.22), value: gridColumn)
            .refreshable {
                await fetchTravelDestinations(shouldShowLoading: false)
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
        ScrollView(.vertical) {
            LazyVStack(spacing: 12) {
                ForEach(travelDestinations, id: \.id) { destination in
                NavigationLink(value: destination) {
                    TravelDestinationListItemView(travelDestination: destination)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(AppTheme.softBorder))
                }
                .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 110)
        }
        .background(AppTheme.appGradient)
        .scrollIndicators(.hidden)
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
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 110)
        }
        .background(AppTheme.appGradient)
        .scrollIndicators(.hidden)
    }
}
