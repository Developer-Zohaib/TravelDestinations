//
//  AppTheme.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI
import UIKit

enum AppTheme {
    static let background = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
        ? UIColor(red: 0.015, green: 0.035, blue: 0.070, alpha: 1)
        : UIColor(red: 0.948, green: 0.967, blue: 0.985, alpha: 1)
    })

    static let surface = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
        ? UIColor(red: 0.055, green: 0.080, blue: 0.125, alpha: 1)
        : UIColor.white
    })

    static let elevatedSurface = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
        ? UIColor(red: 0.078, green: 0.105, blue: 0.160, alpha: 1)
        : UIColor(red: 0.985, green: 0.990, blue: 1.000, alpha: 1)
    })

    static let primaryText = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    static let accent = Color(hex: 0xC99846)
    static let violet = Color(hex: 0x554023)
    static let coral = Color(red: 0.96, green: 0.34, blue: 0.31)
    static let mint = Color(red: 0.06, green: 0.68, blue: 0.58)
    static let gold = Color(red: 0.96, green: 0.68, blue: 0.20)

    static var appGradient: LinearGradient {
        LinearGradient(
            colors: [
                background,
                Color(UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 0.030, green: 0.070, blue: 0.120, alpha: 1)
                    : UIColor(red: 0.910, green: 0.950, blue: 1.000, alpha: 1)
                })
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: 0x554023), Color(hex: 0xC99846)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var softBorder: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.12)
            : UIColor.black.withAlphaComponent(0.08)
        })
    }

    static func configureAppearance() {
        UIView.appearance().tintColor = UIColor(AppTheme.accent)

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = navigationAppearance
        UINavigationBar.appearance().compactAppearance = navigationAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance
    }
}

extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

struct AppLoadingView: View {
    let title: String
    var message: String? = nil

    var body: some View {
        VStack(spacing: 18) {
            AppLoadingMark(size: 72)

            VStack(spacing: 6) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppTheme.primaryText)

                if let message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 30)
        .frame(maxWidth: 280)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.softBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AppLoadingMark: View {
    var size: CGFloat = 48
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.softBorder, lineWidth: size * 0.09)

            Circle()
                .trim(from: 0.12, to: 0.82)
                .stroke(
                    AppTheme.brandGradient,
                    style: StrokeStyle(lineWidth: size * 0.09, lineCap: .round)
                )
                .rotationEffect(.degrees(isAnimating ? 360 : 0))

            Image(systemName: "airplane")
                .font(.system(size: size * 0.34, weight: .bold))
                .foregroundStyle(AppTheme.brandGradient)
                .rotationEffect(.degrees(isAnimating ? 8 : -8))
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.linear(duration: 1.05).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

struct ImageLoadingPlaceholder: View {
    var systemImage = "photo"
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.elevatedSurface)

            AppLoadingMark(size: 34)
                .opacity(0.9)

            Image(systemName: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.secondaryText.opacity(0.45))
                .offset(y: 34)
        }
        .overlay {
            LinearGradient(
                colors: [
                    .white.opacity(0),
                    .white.opacity(isAnimating ? 0.20 : 0.06),
                    .white.opacity(0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blendMode(.overlay)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}
