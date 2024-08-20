//
//  MainView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI

struct MainView: View {
    @StateObject private var firestoreService = FirestoreService.shared

    var body: some View {
        
        TabView {
            
            ContentView()
                .environmentObject(firestoreService)
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Browse")
                }
            
            VideoListView()
                .environmentObject(firestoreService)
                .tabItem {
                    Image(systemName: "play.rectangle")
                    Text("Watch")
                }

            MapView()
                .environmentObject(firestoreService)
                .tabItem {
                    Image(systemName: "map")
                    Text("Locations")
                }

            GalleryView()
                .environmentObject(firestoreService)
                .tabItem {
                    Image(systemName: "photo")
                    Text("Gallery")
                }
        }
    }
}
