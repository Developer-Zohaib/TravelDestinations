//
//  VideoListItemView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI

struct VideoListItemView: View {
    
    let video: Video

    var body: some View {
        
        HStack(spacing: 10) {
            ZStack {
                
                if let url = video.displayThumbnailURL {
                    RemoteImageView(url: url, contentMode: .fit, placeholderSystemImage: "video")
                        .frame(height: 80)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 9)
                        )
                    
                } else {
                    Image(systemName: "video")
                        .frame(width: 120, height: 80)
                        .background(.quaternary)
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                }
                    
                Image(systemName: "play.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 32)
                    .shadow(radius: 4 )
            }
            
            VStack(alignment: .leading, spacing: 8 ) {
                
                Text(video.name)
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundStyle(.accent)
                
                Text(video.headline)
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
        }
    }
}
