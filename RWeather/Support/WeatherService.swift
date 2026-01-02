//
//  WeatherService.swift
//  RWeather
//
//  Created by Rahul on 02/01/2026.
//

import Foundation

class WeatherService {
    private let apiKey = "OpenWeather Api key here"
    
    func getWeather(city: String) async throws -> WeatherData {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric") else { throw URLError(.badURL) }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // CHECK FOR 404 (City Not Found)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
            throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "City not found. Please check the spelling."])
        }
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(WeatherData.self, from: data)
    }
    
    func getForecast(city: String) async throws -> ForecastData {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(apiKey)&units=metric") else { throw URLError(.badURL) }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
            throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "City not found."])
        }
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        
        return try JSONDecoder().decode(ForecastData.self, from: data)
    }
}
