//
//  FirestoreService.swift
//  Travel Destinations
//
//  Created by Zohaib Afzal on 16/07/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreService: ObservableObject {
    static let shared = FirestoreService()
    
    private init() {
           // Private initializer to ensure only one instance is created
       }
    
    private var dataBase = Firestore.firestore()
    
    // Fetch data from Firestore
    func fetchData<T: Decodable>(collection: String, completion: @escaping (Result<[T], Error>) -> Void) {
        dataBase.collection(collection).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                let documents = snapshot.documents.compactMap { document -> T? in
                    try? document.data(as: T.self)
                }
                completion(.success(documents))
            }
        }
    }
    
    func fetchData<T: Decodable>(collection: String) async throws -> [T] {
        try await withCheckedThrowingContinuation { continuation in
            fetchData(collection: collection) { (result: Result<[T], Error>) in
                continuation.resume(with: result)
            }
        }
    }
    
    // Add or update data in Firestore
    func saveData<T: Encodable>(collection: String, data: T, id: String? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            if let id = id {
                try dataBase.collection(collection).document(id).setData(from: data)
            } else {
                try dataBase.collection(collection).addDocument(from: data)
            }
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    // Delete data from Firestore
    func deleteData(collection: String, id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        dataBase.collection(collection).document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

enum ViewState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(String)
}

extension ViewState {
    var loadedValue: Value? {
        guard case .loaded(let value) = self else {
            return nil
        }

        return value
    }

    var shouldPerformInitialLoad: Bool {
        if case .idle = self {
            return true
        }

        return false
    }

    var shouldShowLoader: Bool {
        switch self {
        case .idle, .loading:
            return true
        case .loaded, .failed:
            return false
        }
    }
}
