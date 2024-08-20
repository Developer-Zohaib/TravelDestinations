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
    @State private var isLoading: Bool = false
    @State private var worldLocationData: [WorldLocation] = []
    
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
            
            ForEach(worldLocationData) { location in
                
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
        .overlay(
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
                        .foregroundColor(.accentColor)
                      Spacer()
                        Text("\(latitude)")
                        .font(.footnote)
                        .foregroundColor(.white)
                    }
                    
                    Divider()
                    
                    HStack {
                      Text("Longitude:")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                      Spacer()
                        Text("\(longitude)")
                        .font(.footnote)
                        .foregroundColor(.white)
                    }
                  }
            }
                .onAppear {
                    fetchMapData()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    Color.black
                        .clipShape(
                            RoundedRectangle(cornerRadius: 8)
                        )
                        .opacity(0.6)
                )
                .padding()
            , alignment: .top
        )
    }
    
    private func fetchMapData() {
        isLoading = true
        firestoreService.fetchData(collection: "TravelMapLocations") { (result: Result<[WorldLocation], Error>) in
            isLoading = false
            switch result {
            case .success(let worldLocationData):
                self.worldLocationData = worldLocationData
            case .failure(let error):
                print("Error fetching documents: \(error.localizedDescription)")
            }
        }
    }
}
