//
//  CreditsView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI

struct CreditsView: View {
    var body: some View {
        
        VStack {
            
            Image("compass")
                .resizable()
                .scaledToFit()
                .frame(width: 128, height: 128)
            
            Text("""
    Copyright © Zohaib Afzal
    All right reserved
    """)
            .font(.footnote)
        .multilineTextAlignment(.center)
        }
        .padding()
        .opacity(0.4)
    }
}
