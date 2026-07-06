//
//  TravelDestinationGridItemView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI

struct TravelDestinationGridItemView: View {
    
    let travelDestination: TravelDestination
    private let cornerRadius = 12.0
    private let aspectRatio = 1.45
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.quaternary)
                
                if let url = travelDestination.displayImageURL {
                    RemoteImageView(url: url, contentMode: .fill)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                } else {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
