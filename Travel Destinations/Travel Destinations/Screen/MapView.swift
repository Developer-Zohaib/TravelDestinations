//
//  MapView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject private var firestoreService: FirestoreService
    @State private var viewState: ViewState<[WorldLocation]> = .idle
    
    @State private var mapCameraPostion = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 48.86,
                longitude: 2.35),
            span: MKCoordinateSpan(
                latitudeDelta: 180,
                longitudeDelta: 360
            )
        )
    )
    
    @State private var latitude = 48.86
    @State private var longitude = 2.35

      var body: some View {
        
        Map(position: $mapCameraPostion) {
            
            ForEach(worldLocationData, id: \.id) { location in
                
                Annotation(location.name, coordinate: location.location) {
                    
                    MapAnnotationView(location: location )
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onMapCameraChange(frequency: .continuous, {
            latitude = $0.region.center.latitude
            longitude = $0.region.center.longitude
        })
        .overlay(alignment: .top) {
            VStack(alignment: .leading, spacing: 12) {
                AppHeaderView(title: "Map", highlightedTitle: " Locations")

                HStack(alignment: .center, spacing: 12) {
                    Image("compass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50, alignment: .center)

                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text("Latitude:")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.accent)
                            Spacer()
                            Text("\(latitude)")
                                .font(.footnote)
                                .foregroundColor(AppTheme.primaryText)
                        }

                        Divider()

                        HStack {
                            Text("Longitude:")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.accent)
                            Spacer()
                            Text("\(longitude)")
                                .font(.footnote)
                                .foregroundColor(AppTheme.primaryText)
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(AppTheme.softBorder))
            }
            .padding(.horizontal, 18)
            .padding(.top, 24)
        }
        .overlay {
            if viewState.shouldShowLoader {
                AppLoadingView(
                    title: "Finding Locations",
                    message: "Placing destination pins on the map"
                )
                .padding(.horizontal, 28)
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .task {
            await fetchMapDataIfNeeded()
        }
    }
    
    private var worldLocationData: [WorldLocation] {
        if case .loaded(let locations) = viewState {
            return locations
        }
        
        return []
    }
    
    @MainActor
    private func fetchMapDataIfNeeded() async {
        guard viewState.shouldPerformInitialLoad else {
            return
        }

        await fetchMapData()
    }

    @MainActor
    private func fetchMapData() async {
        viewState = .loading
        
        do {
            let locations: [WorldLocation] = try await firestoreService.fetchData(collection: "TravelMapLocations")
            viewState = .loaded(locations)
            prefetchLocationImages(for: locations)
        } catch {
            viewState = .failed(error.localizedDescription)
        }
    }

    private func prefetchLocationImages(for locations: [WorldLocation]) {
        let urls = locations.compactMap(\.displayImageURL)

        Task(priority: .utility) {
            await ImagePipeline.shared.prefetch(urls)
        }
    }
}
