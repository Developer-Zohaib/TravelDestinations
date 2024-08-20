//
//  TravelDestinationModel.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import Foundation

struct TravelDestination: Codable, Identifiable {
    let id: String
    let name: String
    let headline: String
    let description: String
    let link: String
    let image: String
    let gallery: [String]
    let fact: [String]
}
