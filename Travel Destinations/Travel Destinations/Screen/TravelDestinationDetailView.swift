//
//  TravelDestinationDetailView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI
import Kingfisher

struct TravelDestinationDetailView: View {
    
    let travelDestination: TravelDestination
    
    var body: some View {
        
            ScrollView(.vertical) {
                
                VStack(alignment: .center, spacing: 20) {
                    
                    if let url = URL(string: travelDestination.image) {
                        KFImage(url)
                            .placeholder {
                                ProgressView()
                            }
                            .resizable()
                            .scaledToFit()
                        
                    } else {
                        Text("Invalid URL")
                    }
                    
                    Text(travelDestination.name.uppercased())
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 8)
                        .foregroundStyle(.primary)
                        .underline(color: .accent)
                        .baselineOffset(10)
                    
                    Text(travelDestination.headline)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.accent)
                        .padding(.horizontal)
                    
                    Group {
                        HeadingView(headingImage: "photo.on.rectangle.angled", headingText: "Highlights in Pictures")
                        
                        InsetGalleryView(travelDestination: travelDestination)
                    }
                    .padding(.horizontal)
                    
                    Group {
                        HeadingView(headingImage: "questionmark.circle", headingText: "Did you know?")
                        
                        InsetFactView(travelDestination: travelDestination)
                    }
                    .padding(.horizontal)
                    
                    Group {
                        HeadingView(headingImage: "info.circle", headingText: "All about \(travelDestination.name)")
                        
                        Text(travelDestination.description)
                            .multilineTextAlignment(.leading)
                            .layoutPriority(1)
                    }
                    .padding(.horizontal)
                    
                    Group {
                        HeadingView(headingImage: "map", headingText: "Map Locations")
                        
                        InsetMapView()
                    }
                    .padding(.horizontal)
                    
                    Group {
                        HeadingView(headingImage: "books.vertical", headingText: "Learn More ")
                        
                        ExternalWeblinkView(travelDestination: travelDestination)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Learn about \(travelDestination.name)")
            .navigationBarTitleDisplayMode(.inline)
    }
}
