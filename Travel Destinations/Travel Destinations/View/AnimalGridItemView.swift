//
//  TravelDestinationGridItemView.swift
//  TravelDestinations
//
//  Created by Zohaib Afzal
//

import SwiftUI

struct TravelDestinationGridItemView: View {
    
    let travelDestination: TravelDestination
    
    var body: some View {

        AsyncImage(url: URL(string: travelDestination.image)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if phase.error != nil {
                Text("There was an error loading the image.")
            } else {
                ProgressView()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
