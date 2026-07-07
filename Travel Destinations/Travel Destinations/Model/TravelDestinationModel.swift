//
//  TravelDestinationModel.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import Foundation

struct TravelDestination: Codable, Hashable, Identifiable {
    let id: String
    let name: String
    let headline: String
    let description: String
    let link: String
    let image: String
    let gallery: [String]
    let fact: [String]
}

extension TravelDestination {
    var displayImageURL: URL? {
        DemoImageProvider.destinationImageURL(for: name, original: image)
    }
    
    var displayGalleryURLs: [URL] {
        let resolvedURLs = gallery.compactMap {
            DemoImageProvider.mediaURL(from: $0, destinationName: name)
        }
        
        return resolvedURLs.isEmpty ? DemoImageProvider.galleryURLs(for: name) : resolvedURLs
    }
}

enum DemoImageProvider {
    private static let imageKitBaseURL = "https://ik.imagekit.io/zohaibafzal/TravelDestinations"

    private static let destinationIDs: [String: String] = [
        "tokyo": "tokyo",
        "sydney": "sydney",
        "rome": "rome",
        "santorini": "santorini",
        "glacier national park": "glaciernationalpark",
        "glaciernationalpark": "glaciernationalpark",
        "paris": "paris",
        "bora bora": "borabora",
        "borabora": "borabora",
        "maldives": "maldives"
    ]

    private static let destinationFolders: [String: String] = [
        "tokyo": "Tokyo",
        "sydney": "Sydney",
        "rome": "Rome",
        "santorini": "Santorini",
        "glaciernationalpark": "Glacier National Park",
        "paris": "Paris",
        "borabora": "Bora Bora",
        "maldives": "Maldives"
    ]

    private static let destinationFallbacks: [String: String] = [
        "paris": "https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=1400&q=80",
        "tokyo": "https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?auto=format&fit=crop&w=1400&q=80",
        "sydney": "https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?auto=format&fit=crop&w=1400&q=80",
        "rome": "https://images.unsplash.com/photo-1552832230-c0197dd311b5?auto=format&fit=crop&w=1400&q=80",
        "santorini": "https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?auto=format&fit=crop&w=1400&q=80",
        "glacier national park": "https://images.unsplash.com/photo-1533240332313-0db49b459ad6?auto=format&fit=crop&w=1400&q=80",
        "bora bora": "https://images.unsplash.com/photo-1500930287596-c1ecaa373bb2?auto=format&fit=crop&w=1400&q=80",
        "maldives": "https://images.unsplash.com/photo-1514282401047-d79a71a590e8?auto=format&fit=crop&w=1400&q=80"
    ]
    
    private static let genericFallbacks = [
        "https://images.unsplash.com/photo-1488646953014-85cb44e25828?auto=format&fit=crop&w=1400&q=80",
        "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1400&q=80",
        "https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1400&q=80"
    ]
    
    static func destinationImageURL(for destinationName: String, original: String) -> URL? {
        if let url = mediaURL(from: original, destinationName: destinationName) {
            return url
        }

        if let url = imageKitURL(destinationName: destinationName, assetName: "main") {
            return url
        }
        
        let key = destinationName.lowercased()
        let fallback = destinationFallbacks.first { key.contains($0.key) }?.value ?? genericFallbacks[0]
        return URL(string: fallback)
    }
    
    static func galleryURLs(for destinationName: String) -> [URL] {
        if let id = destinationID(for: destinationName) {
            return (1...5).compactMap {
                imageKitURL(destinationID: id, filename: "\(id)-gallery-\($0).jpg")
            }
        }

        return genericFallbacks.compactMap(URL.init(string:))
    }

    static func mediaURL(from string: String, destinationName: String? = nil) -> URL? {
        if let url = remoteURL(from: string) {
            return url
        }

        return imageKitURL(fromLegacyFirebaseURL: string, destinationName: destinationName)
    }
    
    static func remoteURL(from string: String) -> URL? {
        guard
            let url = URL(string: string),
            let scheme = url.scheme?.lowercased(),
            scheme == "https" || scheme == "http",
            !isFirebaseStorageURL(url)
        else {
            return nil
        }
        
        return url
    }

    private static func imageKitURL(destinationName: String, assetName: String) -> URL? {
        guard let id = destinationID(for: destinationName) else {
            return nil
        }

        return imageKitURL(destinationID: id, filename: "\(id)-\(assetName).jpg")
    }

    private static func imageKitURL(destinationID: String, filename: String) -> URL? {
        guard let folder = destinationFolders[destinationID] else {
            return nil
        }

        let encodedFolder = folder.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? folder
        return URL(string: "\(imageKitBaseURL)/\(encodedFolder)/\(filename)")
    }

    private static func imageKitURL(fromLegacyFirebaseURL string: String, destinationName: String?) -> URL? {
        guard let url = URL(string: string), isFirebaseStorageURL(url) else {
            return nil
        }

        let decodedPath = url.path.removingPercentEncoding ?? url.path
        let rawFilename = decodedPath.components(separatedBy: "/").last ?? ""
        let baseFilename = rawFilename
            .replacingOccurrences(of: ".jpeg", with: "")
            .replacingOccurrences(of: ".jpg", with: "")
            .replacingOccurrences(of: ".png", with: "")
            .lowercased()

        if let galleryRange = baseFilename.range(of: "_gallery_") {
            let rawID = String(baseFilename[..<galleryRange.lowerBound])
            let galleryNumber = baseFilename[galleryRange.upperBound...]
                .split(whereSeparator: { !$0.isNumber })
                .first
                .map(String.init)

            guard let id = normalizedDestinationID(rawID, fallbackName: destinationName),
                  let galleryNumber else {
                return nil
            }

            return imageKitURL(destinationID: id, filename: "\(id)-gallery-\(galleryNumber).jpg")
        }

        if let mainRange = baseFilename.range(of: "_main") {
            let rawID = String(baseFilename[..<mainRange.lowerBound])
            guard let id = normalizedDestinationID(rawID, fallbackName: destinationName) else {
                return nil
            }

            return imageKitURL(destinationID: id, filename: "\(id)-main.jpg")
        }

        if let mapRange = baseFilename.range(of: "_map_pin") {
            let rawID = String(baseFilename[..<mapRange.lowerBound])
            guard let id = normalizedDestinationID(rawID, fallbackName: destinationName) else {
                return nil
            }

            return imageKitURL(destinationID: id, filename: "\(id)-main.jpg")
        }

        if let destinationName {
            return imageKitURL(destinationName: destinationName, assetName: "main")
        }

        return nil
    }

    private static func destinationID(for destinationName: String) -> String? {
        let normalizedName = destinationName
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let id = destinationIDs[normalizedName] {
            return id
        }

        let compactName = compactIdentifier(normalizedName)
        return destinationIDs[compactName]
    }

    private static func normalizedDestinationID(_ rawID: String, fallbackName: String?) -> String? {
        let compactID = compactIdentifier(rawID)
        if let id = destinationIDs[compactID] {
            return id
        }

        if !compactID.isEmpty {
            return compactID
        }

        guard let fallbackName else {
            return nil
        }

        return destinationID(for: fallbackName)
    }

    private static func compactIdentifier(_ value: String) -> String {
        value
            .lowercased()
            .filter { $0.isLetter || $0.isNumber }
    }
    
    private static func isFirebaseStorageURL(_ url: URL) -> Bool {
        guard let host = url.host?.lowercased() else {
            return false
        }
        
        return host.contains("firebasestorage") || host.contains("googleapis")
    }
}
