//
//  TravelDestinationsApp.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI
import FirebaseCore

@main
struct TravelDestinationsApp: App {
    
    init() {
           FirebaseApp.configure()
       }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
