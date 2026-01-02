//
//  WeatherView.swift
//  RWeather
//
//  Created by Rahul on 29/01/2025.
//
import SwiftUI
// MARK: - Forecast View
struct ForecastView: View {
    let forecast: [ForecastItem]
    let weather: WeatherData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // 1. Background
            Image("bgImg")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .opacity(0.6)
            
            // 2. Content
            VStack(spacing: 0) {
                // --- Custom Navigation Header ---
                VStack(alignment: .leading, spacing: 5) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 50)
                            .padding(.leading, 20)
                    }
                    
                    Text("Forecast")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.leading, 20)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)
                
                // --- Center: Current Weather Info ---
                VStack(spacing: 10) {
                    Text(weather.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Image(systemName: WeatherHelper.getWeatherIcon(for: weather.weather.first?.icon ?? ""))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 140, height: 140)
                        .symbolRenderingMode(.multicolor)
                    
                    Text("\(Int(weather.main.temp))°C")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(weather.weather.first?.description.capitalized ?? "")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // --- Bottom: 5-Day Horizontal Card ---
                VStack(spacing: 15) {
                    Text("5-Day Forecast")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 10)
                    
                    HStack(spacing: 25) { // Horizontal list
                        ForEach(forecast.prefix(5), id: \.dt) { item in
                            VStack(spacing: 10) {
                                Text(dateString(item.dt)) // Day (e.g., Mon)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                
                                Image(systemName: WeatherHelper.getWeatherIcon(for: item.weather.first?.icon ?? ""))
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                
                                Text("\(Int(item.main.temp))") // Temp
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.bottom, 15)
                }
                .padding()
                .background(Color.white.opacity(0.15)) // Semi-transparent card
                .cornerRadius(25)
                .padding(.horizontal, 20)
                .padding(.bottom, 180)
            }
        }
        .navigationBarHidden(true)
    }
    
    // Helper for "Mon", "Tue" etc.
    private func dateString(_ timestamp: TimeInterval) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Short day format
        return formatter.string(from: Date(timeIntervalSince1970: timestamp))
    }
}

// Helper for Icons
struct WeatherHelper {
    static func getWeatherIcon(for code: String) -> String {
        switch code {
        case "01d", "01n": return "sun.max.fill"
        case "02d", "02n": return "cloud.sun.fill"
        case "03d", "03n", "04d", "04n": return "cloud.fill"
        case "09d", "09n", "10d", "10n": return "cloud.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "snowflake"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "sun.max.fill"
        }
    }
}
