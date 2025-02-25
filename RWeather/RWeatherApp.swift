//
//  RWeatherApp.swift
//  RWeather
//
//  Created by Rahul on 29/01/2025.
//

import SwiftUI

@main
struct YourApp: App {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                WeatherHomeView()
            } else {
                OnboardingView()
            }
        }
    }
}
