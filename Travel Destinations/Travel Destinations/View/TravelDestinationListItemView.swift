//
//  TravelDestinationListItemView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI
import Kingfisher

struct TravelDestinationListItemView: View {
    
    let travelDestination: TravelDestination
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 16) {
            if let url = URL(string: travelDestination.image) {
                KFImage(url)
                    .placeholder {
                        ProgressView()
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 90)
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
