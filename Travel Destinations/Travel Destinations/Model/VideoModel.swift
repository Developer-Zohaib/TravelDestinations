//
//  VideoModel.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import Foundation

struct Video: Codable, Hashable, Identifiable {
    let id: String
    let name: String
    let headline: String 
    let videoURL: String
    let thumbnail: String
}

extension Video {
    var displayThumbnailURL: URL? {
        DemoImageProvider.remoteURL(from: thumbnail) ?? DemoImageProvider.galleryURLs(for: name).first
    }
}
