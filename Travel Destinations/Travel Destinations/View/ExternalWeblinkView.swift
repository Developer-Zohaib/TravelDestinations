//
//  ExternalWeblinkView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI

struct ExternalWeblinkView: View {
    
    let travelDestination: TravelDestination
    
    var body: some View {
        
        GroupBox {
            HStack {
                Image(systemName: "globe")
                Text("Wikipedia ")
                Spacer()
                
                Group {
                    Link(travelDestination.name, destination: URL(string: travelDestination.link) ?? URL(string: "https://www.wikipedia.org/")!)

                    Image(systemName: "arrow.up.right.square")
                }
                .foregroundStyle(.accent)
            }
        }
    }
}
