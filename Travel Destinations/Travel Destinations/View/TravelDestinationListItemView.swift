//
//  TravelDestinationListItemView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI

struct TravelDestinationListItemView: View {
    
    let travelDestination: TravelDestination
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 16) {
            if let url = travelDestination.displayImageURL {
                RemoteImageView(url: url, contentMode: .fill)
                    .frame(width: 90, height: 90)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )
                
            } else {
                Image(systemName: "photo")
                    .frame(width: 90, height: 90)
                    .background(.quaternary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(travelDestination.name)
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundStyle(.accent)
                
                Text(travelDestination.headline)
                    .font(.footnote )
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .padding(.trailing, 8)
            }
        } 
    }
}
