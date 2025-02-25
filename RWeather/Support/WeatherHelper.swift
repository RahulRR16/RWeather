//
//  WeatherHelper.swift
//  RWeather
//
//  Created by Rahul on 11/02/2025.
//

import Foundation

// Helper function to map weather icon code to SF Symbol
class WeatherHelper {
    
    static func getWeatherIcon(for iconCode: String) -> String {
        switch iconCode {
        case "01d", "01n": return "sun.max.fill" // Clear sky
        case "02d", "02n": return "cloud.sun.fill" // Few clouds
        case "03d", "03n": return "cloud.fill" // Scattered clouds
        case "04d", "04n": return "smoke.fill" // Broken clouds
        case "09d", "09n": return "cloud.rain.fill" // Shower rain
        case "10d", "10n": return "cloud.drizzle.fill" // Rain
        case "11d", "11n": return "cloud.bolt.fill" // Thunderstorm
        case "13d", "13n": return "snowflake" // Snow
        case "50d", "50n": return "cloud.fog.fill" // Mist
        default: return "questionmark.circle.fill" // Unknown
        }
    }
    
}
