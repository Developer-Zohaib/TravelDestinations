//
//  InsetGalleryView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI
import Kingfisher

struct InsetGalleryView: View {
    
    let travelDestination: TravelDestination
    
    var body: some View {
        
        ScrollView(.horizontal) {
            
            HStack(alignment: .center, spacing: 15 ) {
                
                ForEach(travelDestination.gallery, id: \.self) { image in
                    if let url = URL(string: image) {
                        KFImage(url)
                            .placeholder {
                                ProgressView()
                            }
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 12)
                            )
                            .onAppear {
                                print("Image successfully loaded: \(url.absoluteString)")
                            }
                            .onTapGesture {
                                print("Image tapped")
                            }
                        
                    } else {
                        Text("Invalid URL")
                    }

                }
            }
        }
        .scrollIndicators(.hidden)
    }
}
