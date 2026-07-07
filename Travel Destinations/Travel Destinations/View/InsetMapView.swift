//
//  InsetMapView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI
import MapKit

struct InsetMapView: View {
    let travelDestination: TravelDestination

    @EnvironmentObject private var firestoreService: FirestoreService
    @State private var matchingLocation: WorldLocation?
    @State private var mapCameraPostion = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 6.600286, longitude: 16.4377599),
            span: MKCoordinateSpan(latitudeDelta: 60.0, longitudeDelta: 60.0)
        )
    )

    var body: some View {

        Map(position: $mapCameraPostion) {
            if let matchingLocation {
                Annotation(matchingLocation.name, coordinate: matchingLocation.location) {
                    MapAnnotationView(location: matchingLocation)
                }
            }
        }
            .overlay(
                
                NavigationLink(destination: MapView()) {
                    
                    HStack {
                         Image(systemName: "mappin.circle")
                            .foregroundStyle(.white)
                            .imageScale(.large)
                        
                        Text("Locations")
                            .foregroundStyle(.accent)
                            .fontWeight(.bold)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(
                        Color.black
                            .opacity(0.4)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 8)
                            )
                    )
                }
                .padding(12)
                , alignment: .topTrailing
            )
            .frame(height: 256)
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
            .task {
                await fetchMatchingLocation()
            }
    }

    @MainActor
    private func fetchMatchingLocation() async {
        do {
            let locations: [WorldLocation] = try await firestoreService.fetchData(collection: "TravelMapLocations")
            guard let location = locations.first(where: { $0.matches(travelDestination) }) else {
                return
            }

            matchingLocation = location
            mapCameraPostion = .region(
                MKCoordinateRegion(
                    center: location.location,
                    span: MKCoordinateSpan(latitudeDelta: 18.0, longitudeDelta: 18.0)
                )
            )
        } catch {
            // The inset map is decorative; the detail screen should remain usable if map data is unavailable.
        }
    }
}

private extension WorldLocation {
    func matches(_ destination: TravelDestination) -> Bool {
        normalizedMapKey(id) == normalizedMapKey(destination.id)
        || normalizedMapKey(name) == normalizedMapKey(destination.name)
    }

    func normalizedMapKey(_ value: String) -> String {
        String(
            value
                .lowercased()
                .filter { $0.isLetter || $0.isNumber }
        )
    }
}
