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
    @StateObject private var playerController = VideoPlayerController()
    @State private var sliderValue: Double = 0
    
    var body: some View {
        Group {
            if let videoURL {
                ZStack {
                    CustomVideoPlayer(player: playerController.player)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .overlay(alignment: .topTrailing) {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .padding()
                        }

                    playbackOverlay
                }
                .safeAreaInset(edge: .bottom) {
                    if playerController.playbackState == .ready {
                        videoControls
                    }
                }
                .task(id: videoURL) {
                    await MainActor.run {
                        playerController.load(url: videoURL)
                    }
                }
                .onDisappear {
                    playerController.pause()
                }
            } else {
                ContentUnavailableView(
                    "Invalid Video URL",
                    systemImage: "link.badge.plus",
                    description: Text("This video has an invalid or incomplete URL.")
                )
            }
        }
        .tint(.accent)
        .navigationTitle(videoData.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(AppTheme.appGradient.ignoresSafeArea())
    }

    private var videoURL: URL? {
        let trimmedURL = videoData.videoURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if let url = URL(string: trimmedURL) {
            return url
        }

        return URL(string: trimmedURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
    }

    @ViewBuilder
    private var playbackOverlay: some View {
        switch playerController.playbackState {
        case .idle, .loading:
            AppLoadingView(
                title: "Loading Video",
                message: "Preparing \(videoData.name)"
            )
        case .buffering:
            AppLoadingView(
                title: "Buffering Video",
                message: "Waiting for a stable stream"
            )
        case .ready:
            EmptyView()
        case .failed(let message):
            VStack(spacing: 16) {
                Image(systemName: "play.slash")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(.accent)

                Text("Unable to Play Video")
                    .font(.title2.weight(.bold))

                Text(message)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Button {
                    playerController.retry()
                } label: {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .font(.headline.weight(.semibold))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(AppTheme.brandGradient, in: Capsule())
                        .foregroundStyle(.white)
                }
                .padding(.top, 4)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .padding(24)
        }
    }

    private var videoControls: some View {
        VStack(spacing: 12) {
            Slider(
                value: Binding(
                    get: {
                        playerController.isSeeking ? sliderValue : playerController.currentTime
                    },
                    set: { value in
                        sliderValue = value
                    }
                ),
                in: 0...max(playerController.duration, 1),
                onEditingChanged: { isEditing in
                    playerController.isSeeking = isEditing

                    if isEditing {
                        sliderValue = playerController.currentTime
                    } else {
                        playerController.seek(to: sliderValue)
                    }
                }
            )
            .tint(.accent)

            HStack {
                Text(playerController.currentTime.formattedPlaybackTime)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)

                Spacer()

                Text(playerController.duration.formattedPlaybackTime)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 28) {
                Button {
                    playerController.skip(by: -10)
                } label: {
                    Image(systemName: "gobackward.10")
                        .font(.title2.weight(.semibold))
                }
                .accessibilityLabel("Back 10 seconds")

                Button {
                    playerController.togglePlayback()
                } label: {
                    Image(systemName: playerController.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 26, weight: .bold))
                        .frame(width: 62, height: 62)
                        .background(AppTheme.brandGradient, in: Circle())
                        .foregroundStyle(.white)
                }
                .accessibilityLabel(playerController.isPlaying ? "Pause" : "Play")

                Button {
                    playerController.skip(by: 10)
                } label: {
                    Image(systemName: "goforward.10")
                        .font(.title2.weight(.semibold))
                }
                .accessibilityLabel("Forward 10 seconds")
            }
            .buttonStyle(.plain)
            .foregroundStyle(AppTheme.primaryText)
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 18)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppTheme.softBorder)
                .frame(height: 1)
        }
    }
}

private extension Double {
    var formattedPlaybackTime: String {
        guard isFinite, self > 0 else {
            return "0:00"
        }

        let totalSeconds = Int(self.rounded())
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}
