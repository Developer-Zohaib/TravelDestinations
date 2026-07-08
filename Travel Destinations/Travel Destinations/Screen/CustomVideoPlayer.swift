//
//  CustomVideoPlayer.swift
//  Travel Destinations
//
//  Created by Zohaib Afzal on 15/08/2024.
//

import SwiftUI
import AVKit
import AVFoundation

enum VideoPlaybackState: Equatable {
    case idle
    case loading
    case buffering
    case ready
    case failed(String)
}

struct CustomVideoPlayer: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> PlayerSurfaceView {
        let view = PlayerSurfaceView()
        view.setPlayer(player)
        return view
    }
    
    func updateUIView(_ uiView: PlayerSurfaceView, context: Context) {
        uiView.setPlayer(player)
    }

    static func dismantleUIView(_ uiView: PlayerSurfaceView, coordinator: ()) {
        uiView.setPlayer(nil)
    }
}

final class VideoPlayerController: ObservableObject {
    @Published var playbackState: VideoPlaybackState = .idle
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isSeeking = false

    let player = AVPlayer()

    private var currentURL: URL?
    private var itemStatusObservation: NSKeyValueObservation?
    private var keepUpObservation: NSKeyValueObservation?
    private var bufferEmptyObservation: NSKeyValueObservation?
    private var timeControlObservation: NSKeyValueObservation?
    private var timeObserver: Any?
    private var endObserver: NSObjectProtocol?
    private var failureObserver: NSObjectProtocol?
    private var retryTask: Task<Void, Never>?
    private var retryAttempts = 0
    private let maxRetryAttempts = 2

    deinit {
        stopObserving()
    }

    @MainActor
    func load(url: URL) {
        guard currentURL != url else {
            return
        }

        stopObserving()
        currentURL = url
        playbackState = .loading
        isPlaying = false
        currentTime = 0
        duration = 0
        retryAttempts = 0
        configurePlayerItem(for: url)
    }

    @MainActor
    private func configurePlayerItem(for url: URL) {
        player.automaticallyWaitsToMinimizeStalling = true

        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        playerItem.preferredForwardBufferDuration = 2

        player.replaceCurrentItem(with: playerItem)
        observe(item: playerItem)
        player.play()
    }

    @MainActor
    func togglePlayback() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }

    @MainActor
    func seek(to time: Double) {
        guard duration > 0 else {
            return
        }

        let clampedTime = min(max(time, 0), duration)
        currentTime = clampedTime
        let target = CMTime(seconds: clampedTime, preferredTimescale: 600)
        player.seek(to: target, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    @MainActor
    func skip(by seconds: Double) {
        seek(to: currentTime + seconds)
    }

    @MainActor
    func pause() {
        player.pause()
    }

    @MainActor
    func retry() {
        guard let currentURL else {
            return
        }

        retryAttempts = 0
        stopObserving()
        self.currentURL = currentURL
        playbackState = .loading
        configurePlayerItem(for: currentURL)
    }

    private func observe(item: AVPlayerItem) {
        itemStatusObservation = item.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            self?.handle(status: item.status, error: item.error)
        }

        keepUpObservation = item.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self] item, _ in
            guard item.isPlaybackLikelyToKeepUp else {
                return
            }

            DispatchQueue.main.async {
                self?.playbackState = .ready
                self?.player.play()
            }
        }

        bufferEmptyObservation = item.observe(\.isPlaybackBufferEmpty, options: [.new]) { [weak self] item, _ in
            guard item.isPlaybackBufferEmpty else {
                return
            }

            DispatchQueue.main.async {
                if self?.player.rate != 0 {
                    self?.playbackState = .buffering
                }
            }
        }

        timeControlObservation = player.observe(\.timeControlStatus, options: [.initial, .new]) { [weak self] player, _ in
            DispatchQueue.main.async {
                guard let self else {
                    return
                }

                self.isPlaying = player.timeControlStatus == .playing

                if player.timeControlStatus == .waitingToPlayAtSpecifiedRate,
                   self.playbackState != .loading {
                    self.playbackState = .buffering
                } else if player.timeControlStatus == .playing {
                    self.playbackState = .ready
                }
            }
        }

        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.25, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self, !self.isSeeking else {
                return
            }

            self.currentTime = time.seconds.isFinite ? time.seconds : 0

            if let itemDuration = self.player.currentItem?.duration.seconds, itemDuration.isFinite {
                self.duration = itemDuration
            }
        }

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.player.seek(to: .zero)
            self?.player.pause()
            self?.currentTime = 0
        }

        failureObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] notification in
            let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error
            self?.handlePlaybackFailure(error?.localizedDescription ?? "The video could not be played.")
        }
    }

    private func stopObserving() {
        player.pause()
        retryTask?.cancel()

        itemStatusObservation = nil
        keepUpObservation = nil
        bufferEmptyObservation = nil
        timeControlObservation = nil

        if let timeObserver {
            player.removeTimeObserver(timeObserver)
        }

        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }

        if let failureObserver {
            NotificationCenter.default.removeObserver(failureObserver)
        }

        timeObserver = nil
        endObserver = nil
        failureObserver = nil
        retryTask = nil
    }

    private func handle(status: AVPlayerItem.Status, error: Error?) {
        DispatchQueue.main.async {
            switch status {
            case .unknown:
                self.playbackState = .loading
            case .readyToPlay:
                if let itemDuration = self.player.currentItem?.duration.seconds, itemDuration.isFinite {
                    self.duration = itemDuration
                }

                self.player.play()
            case .failed:
                self.handlePlaybackFailure(error?.localizedDescription ?? "The video could not be loaded.")
            @unknown default:
                self.playbackState = .failed("The video is using an unsupported playback state.")
            }
        }
    }

    private func handlePlaybackFailure(_ message: String) {
        guard retryAttempts < maxRetryAttempts, let currentURL else {
            playbackState = .failed(message)
            return
        }

        retryAttempts += 1
        playbackState = .loading
        retryTask?.cancel()
        retryTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(700))

            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                guard let self else {
                    return
                }

                self.stopObserving()
                self.currentURL = currentURL
                self.configurePlayerItem(for: currentURL)
            }
        }
    }
}

final class PlayerSurfaceView: UIView {
    override static var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    private var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurePlayerView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configurePlayerView()
    }
    
    private func configurePlayerView() {
        backgroundColor = .black
        playerLayer.videoGravity = .resizeAspect
    }
    
    func setPlayer(_ player: AVPlayer?) {
        playerLayer.player = player
    }
}
