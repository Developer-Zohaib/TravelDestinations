//
//  GalleryView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI
import Kingfisher

struct GalleryView: View {
    
    @State private var selectedDestination = ""
    
    //Dynamic grid layout
    @State private var gridLayout = [GridItem(.flexible())]
    @State private var gridColumn = 3.0
    @State private var isLoading: Bool = true
    @EnvironmentObject private var firestoreService: FirestoreService
    @State private var travelGalleryCollection: [TravelGalleryCollectionModel] = []
    
    let hapticFeedBack = UINotificationFeedbackGenerator()
    
    func gridSwitch() {
        gridLayout = Array(repeating: GridItem(.flexible()), count: Int(gridColumn) )
    }
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                VStack(alignment: .center, spacing: 30) {
                    if let url = URL(string: selectedDestination) {
                        KFImage(url)
                            .placeholder {
                                ProgressView()
                            }
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300, height: 300)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 8)
                            )
                    } else {
                        Text("Invalid URL")
                    }
                    
                    Slider(value: $gridColumn, in: 2...4)
                        .padding(.horizontal)
                        .onChange(of: gridColumn) {
                            withAnimation(.easeIn) {
                                gridSwitch()
                            }
                        }
                    
                    if let gallery = travelGalleryCollection.first?.gallery {
                        LazyVGrid(columns: gridLayout, alignment: .center, spacing: 10) {
                            ForEach(gallery, id: \.self) { imageurl in
                                if let url = URL(string: imageurl) {
                                    KFImage(url)
                                        .placeholder {
                                            ProgressView()
                                        }
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(Color.white, lineWidth: 1)
                                        )
                                        .frame(width: 150, height: 150)
                                        .onTapGesture {
                                            hapticFeedBack.notificationOccurred(.success)
                                            selectedDestination = imageurl
                                        }
                                } else {
                                    Text("Invalid URL")
                                }
                            }
                        }
                        .onAppear {
                            gridSwitch()
                        }
                    }
                    
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 50)
            }
            .refreshable {
                fetchTravelGalleryCollection()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(MotionAnimationView())
            
            if isLoading {
                // Loading overlay
                ProgressView("Loading...")
                    .onAppear {
                        fetchTravelGalleryCollection()
                    }
            }
        }
    }
    
    private func fetchTravelGalleryCollection() {
        isLoading = true
        firestoreService.fetchData(collection: "TravelGalleryCollection") { (result: Result<[TravelGalleryCollectionModel], Error>) in
            isLoading = false
            switch result {
            case .success(let travelGalleryCollection):
                self.travelGalleryCollection = travelGalleryCollection
                selectedDestination = self.travelGalleryCollection.first?.gallery.first ?? ""
                
            case .failure(let error):
                print("Error fetching documents: \(error.localizedDescription)")
            }
        }
    }
}
