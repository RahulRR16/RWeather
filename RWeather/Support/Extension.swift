//
//  Extension.swift
//  RWeather
//
//  Created by Rahul on 02/01/2026.
//

import SwiftUI
extension View {
    func gradientButtonStyle() -> some View {
        self
            .background(
                ZStack {
                    // 1. The Main Gradient Background
                    RoundedRectangle(cornerRadius: 25)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.orange, .black]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // 2. The White Border (Added as an overlay)
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white, lineWidth: 0.5)
                }
                // 3. Shadow applied to the whole stack
                    .shadow(color: .yellow.opacity(0.10), radius: 10, x: 0, y: 5)
            )
    }
}
