//
//  MapAnnotationView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI

struct MapAnnotationView: View {
    
    var location: WorldLocation
    
    @State private var animation = 0.0
     
    var body: some View {
        
        ZStack {
            
            Circle()
                .fill(.accent)
                .frame(width: 54, height: 54, alignment: .center)
            
            Circle()
                .stroke(Color.accentColor, lineWidth: 2)
                .frame(width: 52, height: 52, alignment: .center)
                .scaleEffect(1 + CGFloat(animation))
                .opacity(1 - animation)
            
            if let url = location.displayImageURL {
                RemoteImageView(url: url, contentMode: .fill, placeholderSystemImage: "mappin")
                    .frame(width: 48, height: 48, alignment: .center)
                    .clipShape(Circle())
                
            } else {
                Image(systemName: "mappin")
                    .frame(width: 48, height: 48, alignment: .center)
                    .background(.quaternary)
                    .clipShape(Circle())
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 2).repeatForever(autoreverses: false)) {
                 animation = 1
            }
        }
    }
}
