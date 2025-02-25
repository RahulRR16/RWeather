//
//  OnboardingPage.swift
//  RWeather
//
//  Created by Rahul on 11/02/2025.
//

import SwiftUI

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    
    var body: some View {
        ZStack {
            // Gradient background
//            LinearGradient(gradient: Gradient(colors: [Color.black, Color.purple]),
//                           startPoint: .topLeading,
//                           endPoint: .bottomTrailing)
//            .edgesIgnoringSafeArea(.all)
            // Background Image
                        Image("launchImg") // Replace with your image name
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all) // Extends to full screen
            
            VStack {
                TabView {
                    OnboardingPage(
                        imageName: "cloud.sun.fill",
                        title: "Welcome to RWeather",
                        description: "Get accurate weather forecasts for any location"
                    )
                    
                    OnboardingPage(
                        imageName: "map.fill",
                        title: "Global Coverage",
                        description: "Search for any city worldwide and get detailed weather information"
                    )
                    
                    OnboardingPage(
                        imageName: "calendar.badge.clock",
                        title: "5-Day Forecast",
                        description: "Plan ahead with our detailed 5-day weather predictions"
                    )
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // "Get Started" button
                Button(action: {
                    hasCompletedOnboarding = true
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.orange, Color.black]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .shadow(color: .yellow.opacity(0.10), radius: 10, x: 0, y: 5)
                        )
                }
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPage: View {
    let imageName: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .symbolRenderingMode(.multicolor) // Enable multicolor rendering
                .foregroundStyle(.yellow, .orange, .white) // Apply multiple colors
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
    }
}
