//
//  OnboardingPage.swift
//  RWeather
//
//  Created by Rahul on 11/02/2025.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    
    var body: some View {
        ZStack {
            // 1. BACKGROUND LAYER
            Image("launchImg")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            // 2. CONTENT LAYER
            VStack {
                // TabView creates the swipeable pages.
                TabView {
                    // Page 1
                    OnboardingPage(
                        imageName: "cloud.sun.fill",
                        title: "Welcome to RWeather",
                        description: "Get accurate weather forecasts for any location"
                    )
                    
                    // Page 2
                    OnboardingPage(
                        imageName: "map.fill",
                        title: "Global Coverage",
                        description: "Search for any city worldwide and get detailed weather information"
                    )
                    
                    // Page 3
                    OnboardingPage(
                        imageName: "calendar.badge.clock",
                        title: "5-Day Forecast",
                        description: "Plan ahead with our detailed 5-day weather predictions"
                    )
                }
                .tabViewStyle(.page) // Turns the TabView into a swipeable carousel with dots.
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // 3. ACTION BUTTON
                Button(action: {
                    // Setting this to true saves it to AppStorage.
                    hasCompletedOnboarding = true
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .gradientButtonStyle()
                }
                .padding(.bottom, 40) // Pushes the button up from the bottom edge
            }
        }
    }
}

// A reusable subview for individual onboarding pages
struct OnboardingPage: View {
    let imageName: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .symbolRenderingMode(.multicolor) // Enables multi-color system icons
                .foregroundStyle(.yellow, .orange, .white) // Fallback colors if multicolor isn't supported
            
            // Title
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Description
            Text(description)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
    }
}
