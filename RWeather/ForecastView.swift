//
//  WeatherView.swift
//  RWeather
//
//  Created by Rahul on 29/01/2025.
//

import SwiftUI


struct ForecastView: View {
    @Environment(\.dismiss) private var dismiss
    var weatherData: WeatherData? // Holds fetched weather data
    var forecastData: ForecastData? // Holds 5-Day Forecast data
    
    var body: some View {
        ZStack {
            Image("bgImg")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                if let weatherData = weatherData {
                    // City name
                    Text(weatherData.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Weather icon
                    if let weather = weatherData.weather.first {
                        Image(systemName: WeatherHelper.getWeatherIcon(for: weather.icon))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .symbolRenderingMode(.multicolor)
                            .foregroundStyle(.yellow, .orange, .white)
                            .frame(width: 100, height: 100)
                    }
                    
                    // Temperature
                    Text("\(weatherData.main.temp, specifier: "%.1f")°C")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Weather condition
                    if let weather = weatherData.weather.first {
                        Text(weather.description.capitalized)
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    // Forecast section
                    if let forecastData = forecastData {
                        VStack(spacing: 10) {
                            Text("5-Day Forecast")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 20) {
                                ForEach(getNextFiveDaysForecast(from: forecastData), id: \.dt) { item in
                                    var tempProperty: String {
                                        return String(format: "%.1f", item.main.temp)
                                    }
                                    ForecastDayView(
                                        day: formatDate(item.dt, format: "EEE"), // Day (e.g., "Mon")
                                        icon: WeatherHelper.getWeatherIcon(for: item.weather.first?.icon ?? ""),
                                        temp: tempProperty
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Forecast")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.headline)
                }
            }
        }
    }
    
    // Helper function to get the next 5 days of forecast data
    private func getNextFiveDaysForecast(from forecastData: ForecastData) -> [ForecastItem] {
        let calendar = Calendar.current
        var uniqueDays: [Date: ForecastItem] = [:]
        
        for item in forecastData.list {
            let date = Date(timeIntervalSince1970: item.dt)
            let dayStart = calendar.startOfDay(for: date)
            
            // Only keep one forecast item per day
            if uniqueDays[dayStart] == nil {
                uniqueDays[dayStart] = item
            }
            
            // Stop after collecting 5 days
            if uniqueDays.count >= 5 {
                break
            }
        }
        
        // Sort the dictionary by date (keys) and return the values in order
        let sortedDays = uniqueDays.sorted { $0.key < $1.key }
        return sortedDays.map { $0.value }
    }
    
    // Helper function to format date
    private func formatDate(_ timestamp: TimeInterval, format: String) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}

// Forecast day view
struct ForecastDayView: View {
    var day: String
    var icon: String
    var temp: String
    
    var body: some View {
        VStack {
            Text(day)
                .font(.subheadline)
                .foregroundColor(.white)
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .symbolRenderingMode(.multicolor)
                .foregroundStyle(.yellow, .orange, .white)
            Text(temp)
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}

struct WeatherAppView_Previews: PreviewProvider {
    static var previews: some View {
        ForecastView()
    }
}
