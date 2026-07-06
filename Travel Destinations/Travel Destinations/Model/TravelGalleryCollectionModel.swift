//
//  TravelGalleryCollectionModel.swift
//  Travel Destinations
//
//  Created by Zohaib Afzal on 30/07/2024.
//

import Foundation

struct TravelGalleryCollectionModel: Codable, Hashable {
    let gallery: [String]
}

extension TravelGalleryCollectionModel {
    var displayGalleryURLs: [URL] {
        let resolvedURLs = gallery.compactMap {
            DemoImageProvider.mediaURL(from: $0)
        }
        
        return resolvedURLs.isEmpty ? DemoImageProvider.galleryURLs(for: "travel") : resolvedURLs
    }
}
