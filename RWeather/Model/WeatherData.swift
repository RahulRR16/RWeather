//
//  WeatherData.swift
//

import Foundation

struct WeatherData: Codable, Equatable {
    let name: String
    let main: Main
    let weather: [Weather]
}

// Model for 5-Day Forecast
struct ForecastData: Codable, Equatable {
    let list: [ForecastItem]
}

struct ForecastItem: Codable, Equatable {
    let dt: TimeInterval
    let main: Main
    let weather: [Weather]
}

struct Main: Codable, Equatable {
    let temp: Double
    let humidity: Int
}
struct Weather: Codable, Equatable {
    let description: String
    let icon: String
}
