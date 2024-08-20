//
//  VideoPlayerView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    
    var videoData: Video
    
    var body: some View {
        
        VStack {
            CustomVideoPlayer(videoURL: URL(string: videoData.videoURL)!)
                .overlay(
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .padding()
                    , alignment: .topTrailing
                )
        }
        .tint(.accent)
        .navigationTitle(videoData.name)
    }
}
