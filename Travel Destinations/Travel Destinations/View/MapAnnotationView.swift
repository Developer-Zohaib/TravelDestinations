//
//  MapAnnotationView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI
import Kingfisher

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
            
            if let url = URL(string: location.image) {
                KFImage(url)
                    .placeholder {
                        ProgressView()
                    }
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48, alignment: .center)
                    .clipShape(Circle())
                
            } else {
                Text("Invalid URL")
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 2).repeatForever(autoreverses: false)) {
                 animation = 1
            }
        }
    }
}
