//
//  StorageService.swift
//  Travel Destinations
//
//  Created by Zohaib Afzal on 16/07/2024.
//

import Foundation
import FirebaseStorage
import UIKit

class StorageService: ObservableObject {
    private var storage = Storage.storage()
    
    // Fetch image from Firebase Storage
    func fetchImage(url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let storageRef = storage.reference(forURL: url)
        
        storageRef.getData(maxSize:  5 * 1024 * 1024) { data, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                completion(.failure(NSError(domain: "ImageError", code: 0, userInfo: nil)))
            }
        }
    }
}
