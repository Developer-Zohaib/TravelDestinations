//
//  LocationModel.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import MapKit

struct WorldLocation : Codable, Identifiable {
    let id: String
    let name: String
    let image: String
    let latitude: Double
    let longitude: Double
    
    // Computed Property
     var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
