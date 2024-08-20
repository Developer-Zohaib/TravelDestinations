//
//  ContentView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI

struct ContentView: View {
    
    @State private var isGridViewActive = false
    
    //Dynamic grid layout
    @State private var gridLayout = [GridItem(.flexible())]
    @State private var gridColumn = 2
    @State private var toolbarIcon = "square.grid.2x2"
    @State private var images: [String: UIImage] = [:]
    @State private var isLoading: Bool = false
    @EnvironmentObject private var firestoreService: FirestoreService
    @State private var travelDestinations: [TravelDestination] = []
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
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading...")
                } else {
                    if !isGridViewActive {
                        ListView(travelDestinations: travelDestinations, images: images)
                            .refreshable {
                                fetchTravelDestinations()
                            }
                    } else {
                        GridView(travelDestinations: travelDestinations, images: images, gridLayout: gridLayout)
                            .refreshable {
                                fetchTravelDestinations()
                            }
                    }
                }
            }
            .navigationTitle("Travel Destinations")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            isGridViewActive = false
                            hapticFeedBack.notificationOccurred(.success)
                        }, label: {
                            Image(systemName: "square.fill.text.grid.1x2")
                                .font(.title2)
                                .foregroundColor(isGridViewActive ? .primary : .accentColor)
                        })
                        
                        Button(action: {
                            isGridViewActive = true
                            hapticFeedBack.notificationOccurred(.success)
                            withAnimation(.easeIn) {
                                gridSwitch()
                            }
                        }, label: {
                            Image(systemName: toolbarIcon)
                                .font(.title2)
                                .foregroundColor(isGridViewActive ? .accentColor : .primary)
                        })
                    }
                }
            }
            .onAppear {
                if travelDestinations.isEmpty {
                    fetchTravelDestinations()
                } else {
                    isLoading = false
                }
            }
        }
    }
    
    private func fetchTravelDestinations() {
        isLoading = true
        firestoreService.fetchData(collection: "TravelDestinations") { (result: Result<[TravelDestination], Error>) in
            isLoading = false
            switch result {
            case .success(let travelDestinations):
                self.travelDestinations = travelDestinations
            case .failure(let error):
                print("Error fetching documents: \(error.localizedDescription)")
            }
        }
    }
}


struct ListView: View {
    let travelDestinations: [TravelDestination]
    let images: [String: UIImage]
    
    var body: some View {
        List {
            ForEach(travelDestinations) { destination in
                NavigationLink(destination: TravelDestinationDetailView(travelDestination: destination)) {
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
    let images: [String: UIImage]
    let gridLayout: [GridItem]
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: gridLayout, alignment: .center, spacing: 10) {
                ForEach(travelDestinations) { destination in
                    NavigationLink(destination: TravelDestinationDetailView(travelDestination: destination)) {
                        TravelDestinationGridItemView(travelDestination: destination)
                    }
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
}
