//
//  InsetGalleryView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI

struct InsetGalleryView: View {
    
    let travelDestination: TravelDestination
    
    var body: some View {
        
        ScrollView(.horizontal) {
            
            HStack(alignment: .center, spacing: 15 ) {
                
                ForEach(Array(travelDestination.displayGalleryURLs.enumerated()), id: \.offset) { _, url in
                    RemoteImageView(url: url, contentMode: .fit)
                        .frame(height: 200)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 12)
                        )

                }
            }
        }
        .scrollIndicators(.hidden)
    }
}
