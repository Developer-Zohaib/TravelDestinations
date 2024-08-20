//
//  VideoModel.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import Foundation

struct Video: Codable, Identifiable {
    let id: String
    let name: String
    let headline: String 
    let videoURL: String
    let thumbnail: String
}
