//
//  ImagePipeline.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import CryptoKit
import Foundation
import UIKit

enum ImagePipelineError: Error {
    case invalidResponse
    case invalidImageData
}

actor ImagePipeline {
    static let shared = ImagePipeline()

    private let memoryCache = NSCache<NSURL, UIImage>()
    private let urlSession: URLSession
    private let fileManager: FileManager
    private let diskCacheDirectory: URL
    private var runningRequests: [URL: Task<UIImage, Error>] = [:]

    init(
        urlSession: URLSession = .shared,
        fileManager: FileManager = .default
    ) {
        self.urlSession = urlSession
        self.fileManager = fileManager

        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskCacheDirectory = cacheDirectory.appendingPathComponent("RemoteImageCache", isDirectory: true)

        memoryCache.countLimit = 250
        memoryCache.totalCostLimit = 100 * 1024 * 1024
    }

    func image(for url: URL) async throws -> UIImage {
        let cacheKey = url as NSURL

        if let image = memoryCache.object(forKey: cacheKey) {
            return image
        }

        if let image = imageFromDisk(for: url) {
            memoryCache.setObject(image, forKey: cacheKey, cost: image.cacheCost)
            return image
        }

        if let runningRequest = runningRequests[url] {
            return try await runningRequest.value
        }

        let request = Task<UIImage, Error> {
            let image = try await self.downloadImage(from: url)
            self.store(image, for: url)
            return image
        }

        runningRequests[url] = request

        do {
            let image = try await request.value
            runningRequests[url] = nil
            return image
        } catch {
            runningRequests[url] = nil
            throw error
        }
    }

    func cachedImage(for url: URL) -> UIImage? {
        let cacheKey = url as NSURL

        if let image = memoryCache.object(forKey: cacheKey) {
            return image
        }

        if let image = imageFromDisk(for: url) {
            memoryCache.setObject(image, forKey: cacheKey, cost: image.cacheCost)
            return image
        }

        return nil
    }

    func prefetch(_ urls: [URL]) async {
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask {
                    _ = try? await self.image(for: url)
                }
            }
        }
    }

    func clearCache() {
        memoryCache.removeAllObjects()

        guard fileManager.fileExists(atPath: diskCacheDirectory.path) else {
            return
        }

        try? fileManager.removeItem(at: diskCacheDirectory)
    }

    private func downloadImage(from url: URL) async throws -> UIImage {
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        request.timeoutInterval = 30

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ImagePipelineError.invalidResponse
        }

        guard let image = UIImage(data: data) else {
            throw ImagePipelineError.invalidImageData
        }

        return image
    }

    private func store(_ image: UIImage, for url: URL) {
        let cacheKey = url as NSURL
        memoryCache.setObject(image, forKey: cacheKey, cost: image.cacheCost)

        guard let data = image.jpegData(compressionQuality: 0.92) else {
            return
        }

        try? fileManager.createDirectory(
            at: diskCacheDirectory,
            withIntermediateDirectories: true
        )

        try? data.write(to: diskCacheURL(for: url), options: .atomic)
    }

    private func imageFromDisk(for url: URL) -> UIImage? {
        let fileURL = diskCacheURL(for: url)

        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }

        return image
    }

    private func diskCacheURL(for url: URL) -> URL {
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        let filename = digest.map { String(format: "%02x", $0) }.joined()
        return diskCacheDirectory.appendingPathComponent("\(filename).jpg")
    }
}

private extension UIImage {
    var cacheCost: Int {
        guard let cgImage else {
            return 1
        }

        return cgImage.bytesPerRow * cgImage.height
    }
}
