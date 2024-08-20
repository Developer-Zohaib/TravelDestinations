//
//  VideoListItemView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI
import Kingfisher

struct VideoListItemView: View {
    
    let video: Video
    @State private var isLoading: Bool = true

    var body: some View {
        
        HStack(spacing: 10) {
            ZStack {
                
                if let url = URL(string: video.thumbnail) {
                    KFImage(url)
                        .placeholder {
                            ProgressView()
                        }
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 9)
                        )
                    
                } else {
                    Text("Invalid URL")
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
