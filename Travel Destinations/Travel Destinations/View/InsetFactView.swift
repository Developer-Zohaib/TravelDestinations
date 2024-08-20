//
//  InsetFactView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI

struct InsetFactView: View {
    
    let travelDestination: TravelDestination
    
    var body: some View {
        
        GroupBox {
            TabView {
                ForEach(travelDestination.fact, id: \.self) { fact in
                    Text(fact)
                }
            }
            .tabViewStyle(.page)
            .frame(minHeight: 148, idealHeight: 168, maxHeight: 180)
        }
    }
}
