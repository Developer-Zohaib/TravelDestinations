//
//  VideoPlayerHelper.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import Foundation
import AVKit

var videoPlayer: AVPlayer?

func playVideo(videoURL: String) -> AVPlayer {
    
    if let url = URL(string: videoURL){
        videoPlayer = AVPlayer(url: url)
        videoPlayer?.play()
    }
    
    return videoPlayer!
}
