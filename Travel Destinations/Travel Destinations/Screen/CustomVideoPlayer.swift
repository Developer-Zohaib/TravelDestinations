//
//  CustomVideoPlayer.swift
//  Travel Destinations
//
//  Created by Zohaib Afzal on 15/08/2024.
//

import SwiftUI
import AVKit
import AVFoundation

struct CustomVideoPlayer: UIViewRepresentable {
    var videoURL: URL
    let videoPlayerView = ActivityIndicatorPlayer()
    
    func makeUIView(context: Context) -> ActivityIndicatorPlayer {
        let player = AVPlayer(url: videoURL)
        videoPlayerView.setPlayer(player: player)
        videoPlayerView.startLoading()
        
        player.addObserver(context.coordinator, forKeyPath: "status", options: [.old, .new], context: nil)
        
        return videoPlayerView
    }
    
    func updateUIView(_ uiView: ActivityIndicatorPlayer, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: CustomVideoPlayer
        
        init(_ parent: CustomVideoPlayer) {
            self.parent = parent
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "status", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int {
                if newValue == AVPlayer.Status.readyToPlay.rawValue {
                    parent.videoPlayerView.stopLoading()                    
                }
            }
        }
    }
}

class ActivityIndicatorPlayer: UIView {
    private let playerViewController = AVPlayerViewController()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurePlayerView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configurePlayerView()
    }
    
    private func configurePlayerView() {
        addSubview(playerViewController.view)
        addSubview(activityIndicator)
        
        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            playerViewController.view.topAnchor.constraint(equalTo: topAnchor),
            playerViewController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            playerViewController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            playerViewController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func setPlayer(player: AVPlayer?) {
        playerViewController.player = player
    }
    
    func startLoading() {
        activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        activityIndicator.stopAnimating()
    }
}
