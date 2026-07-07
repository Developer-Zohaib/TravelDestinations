//
//  HeadingView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI

struct HeadingView: View {
    
    var headingImage: String
    var headingText: String
    
    var body: some View {
        
        HStack {
            
            Image(systemName: headingImage)
                .foregroundStyle(.accent)
                .imageScale(.large)
            
            Text(headingText)
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding(.vertical)
    }
}

struct AppHeaderView<Trailing: View>: View {
    let title: String
    let highlightedTitle: String
    let subtitle: String?
    @ViewBuilder let trailing: Trailing

    init(
        title: String,
        highlightedTitle: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.highlightedTitle = highlightedTitle
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 7) {
                (Text(title)
                    .foregroundStyle(AppTheme.primaryText)
                + Text(highlightedTitle)
                    .foregroundStyle(AppTheme.brandGradient))
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)

                if let subtitle {
                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 8)

            trailing
        }
    }
}

extension AppHeaderView where Trailing == EmptyView {
    init(title: String, highlightedTitle: String, subtitle: String? = nil) {
        self.init(title: title, highlightedTitle: highlightedTitle, subtitle: subtitle) {
            EmptyView()
        }
    }
}
