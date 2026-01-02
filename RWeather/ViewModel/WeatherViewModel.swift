//
//  WeatherViewModel.swift
//  RWeather
//
//  Created by Rahul on 02/01/2026.
//
import SwiftUI
import CoreLocation

@MainActor
class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var weather: WeatherData?
    @Published var forecast: [ForecastItem] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    private let service = WeatherService()
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func requestLocation() {
        isLoading = true
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            // Do not call requestLocation() yet; wait for delegate
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            isLoading = false
            errorMessage = "Location permission denied. Please enable it in Settings."
            showError = true
        @unknown default:
            break
        }
    }
    
    func searchCity() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        fetchWeather(for: query)
    }
    
    private func fetchWeather(for city: String) {
        isLoading = true
        errorMessage = nil
        showError = false
        
        Task {
            do {
                // 1. Fetch Data (API Call)
                async let weatherData = service.getWeather(city: city)
                async let forecastData = service.getForecast(city: city)
                
                // 2. Wait for data
                let fetchedWeather = try await weatherData
                let fetchedForecast = try await forecastData
                
                // 3. ARTIFICIAL DELAY (Wait 1 second so user sees the loader)
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
                // 4. Update UI
                self.weather = fetchedWeather
                self.forecast = processForecast(fetchedForecast)
                self.isLoading = false
            } catch {
                try? await Task.sleep(nanoseconds: 500_000_000)
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
    
    private func processForecast(_ data: ForecastData) -> [ForecastItem] {
        let calendar = Calendar.current
        var uniqueDays: [Date: ForecastItem] = [:]
        
        for item in data.list {
            let date = Date(timeIntervalSince1970: item.dt)
            let dayStart = calendar.startOfDay(for: date)
            if uniqueDays[dayStart] == nil {
                uniqueDays[dayStart] = item
            }
            if uniqueDays.count >= 5 { break }
        }
        return uniqueDays.sorted { $0.key < $1.key }.map { $0.value }
    }
    
    // MARK: - Location Manager Delegates
    // 1. Handle Permission Change
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation() // Auto-load once permission granted
            case .denied, .restricted:
                self.isLoading = false
                self.errorMessage = "Permission denied."
                self.showError = true
            case .notDetermined:
                break // Wait for user
            @unknown default:
                break
            }
        }
    }
    
    // 2. Handle Location Update
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        Task { @MainActor in
            self.reverseGeocode(location: location)
        }
    }
    
    // 3. Handle Errors
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.isLoading = false
            // Ignore common simulator errors
            if let clError = error as? CLError, clError.code == .locationUnknown { return }
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }
    
    private func reverseGeocode(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let city = placemarks?.first?.locality {
                self.searchText = city
                self.fetchWeather(for: city)
            } else {
                self.isLoading = false
                self.errorMessage = "Could not identify city."
                self.showError = true
            }
        }
    }
    
}
