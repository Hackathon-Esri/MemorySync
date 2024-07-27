//
//  AerialView.swift
//  Chrononauts
//
//  Created by FredyCamas on 7/26/24.
//

import SwiftUI

struct AerialView: View {
    var panorama: Panorama
    
    var body: some View {
        VStack {
            Text("Panorama: \(panorama.name)") // Displaying some panorama data
            // Additional UI elements to display panorama data
        }
    }
}
