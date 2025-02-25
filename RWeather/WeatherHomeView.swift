////
////  ContentView.swift
////  RWeather
////
////  Created by Rahul on 29/01/2025.
////
//

import SwiftUI
import CoreLocation

struct WeatherHomeView: View {
    
    @StateObject private var locationManager = LocationManager()
    @State private var searchText: String = ""
    @State private var cityName: String = ""
    @State private var showForecast: Bool = false
    @State private var weatherData: WeatherData?
    @State private var forecastData: ForecastData?
    @State private var isLoading: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var isFirstAppear: Bool = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("bgImg")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                // Tap gesture to dismiss the keyboard
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        dismissKeyboard()
                    }
                
                // Main content
                VStack(spacing: 20) {
                    // Search bar and location icon
                    HStack {
                        // Current location button
                        Button(action: fetchCurrentLocation) {
                            if locationManager.isFetchingLocation {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(width: 30, height: 30)
                            } else {
                                Image(systemName: "location.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        TextField("", text: $searchText)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .placeholder(when: searchText.isEmpty) {
                                Text("Search for a city name")
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.leading, 10)
                            }
                            .onChange(of: searchText) {
                                handleSearchTextChange(searchText)
                            }
                            .onSubmit {
                                fetchWeatherAndForecastData(for: searchText)
                            }
                        
                        // Search button with API call
                        Button(action: {
                            fetchWeatherAndForecastData(for: searchText)
                        }) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(width: 30, height: 30)
                            } else {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(isLoading)
                    }
                    .padding(.horizontal)
                    
                    // City name and weather details
                    if !searchText.isEmpty, let weatherData = weatherData {
                        WeatherDetailsView(weatherData: weatherData)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.5), value: weatherData)
                    } else if searchText.isEmpty && !cityName.isEmpty {
                        Text(cityName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 5, x: 0, y: 0)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.5), value: cityName)
                    }
                    
                    // 5-Day Forecast button
                    if showForecast {
                        NavigationLink(destination: ForecastView(weatherData: weatherData, forecastData: forecastData)) {
                            Text("View 5-Day Forecast")
                                .font(.headline)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 5, x: 0, y: 0)
                        }
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.5), value: showForecast)
                    }
                }
                .padding()
                
                // Activity loader for initial location fetch
                if isFirstAppear && locationManager.isFetchingLocation {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                }
            }
            .navigationTitle("RWeather")
            .navigationBarTitleTextColor(Color.white)
            .onAppear {
                if isFirstAppear {
                    fetchCurrentLocation()
                    isFirstAppear = false // Mark initial appearance as complete
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK")) {
                        showErrorAlert = false
                    }
                )
            } .preferredColorScheme(.dark)
        }
    }
    
    // MARK: - Helper Functions
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func handleSearchTextChange(_ newValue: String) {
        let filteredText = newValue.filter { !$0.isNumber }
        if filteredText != newValue {
            searchText = filteredText
        }
        
        if newValue.isEmpty {
            weatherData = nil
            forecastData = nil
            cityName = ""
            showForecast = false
        }
    }
    
    private func fetchWeatherAndForecastData(for city: String) {
        guard !city.isEmpty else { return }
        
        isLoading = true
        
        let apiKey = "OpenWeather Api key here"
        let weatherURLString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"
        let forecastURLString = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(apiKey)&units=metric"
        
        let group = DispatchGroup()
        var weatherData: WeatherData?
        var forecastData: ForecastData?
        var errorMessage: String?
        
        // Fetch current weather data
        group.enter()
        fetchData(from: weatherURLString) { (result: Result<WeatherData, Error>) in
            defer { group.leave() }
            switch result {
            case .success(let data):
                weatherData = data
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
        
        // Fetch 5-Day Forecast data
        group.enter()
        fetchData(from: forecastURLString) { (result: Result<ForecastData, Error>) in
            defer { group.leave() }
            switch result {
            case .success(let data):
                forecastData = data
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
        
        // Handle completion
        group.notify(queue: .main) {
            isLoading = false
            if let errorMessage = errorMessage {
                self.errorMessage = errorMessage
                self.showErrorAlert = true
            } else {
                self.weatherData = weatherData
                self.forecastData = forecastData
                self.cityName = weatherData?.name ?? "Unknown Location"
                self.showForecast = true
            }
        }
    }
    
    private func fetchData<T: Decodable>(from urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func fetchCurrentLocation() {
        locationManager.isFetchingLocation = true
        
        if let location = locationManager.location {
            reverseGeocode(location)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                if let updatedLocation = locationManager.location {
                    reverseGeocode(updatedLocation)
                } else {
                    locationManager.isFetchingLocation = false
                    self.errorMessage = "Location not available"
                    self.showErrorAlert = true
                }
            }
        }
    }
    
    private func reverseGeocode(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            locationManager.isFetchingLocation = false
            
            if let error = error {
                self.errorMessage = "Reverse geocoding failed: \(error.localizedDescription)"
                self.showErrorAlert = true
                return
            }
            
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? "Unknown Location"
                self.cityName = city
                self.searchText = city
                self.fetchWeatherAndForecastData(for: city)
            } else {
                self.errorMessage = "Location not available"
                self.showErrorAlert = true
            }
        }
    }
}

// MARK: - Subviews

struct WeatherDetailsView: View {
    var weatherData: WeatherData
    var body: some View {
        VStack {
            Text(weatherData.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(color: .black, radius: 5, x: 0, y: 0)
            
            Text("\(weatherData.main.temp, specifier: "%.1f")°C")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black, radius: 5, x: 0, y: 0)
            
            if let weather = weatherData.weather.first {
                HStack {
                    Image(systemName: WeatherHelper.getWeatherIcon(for: weather.icon))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .symbolRenderingMode(.multicolor)
                        .foregroundStyle(.yellow, .orange, .white)
                    Text(weather.description.capitalized)
                        .font(.title2)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 5, x: 0, y: 0)
                }
            }
        }
    }
}

// MARK: - Preview

struct WeatherHomeView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherHomeView()
    }
}

// MARK: - Extensions

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
    
    @available(iOS 14, *)
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor]
        return self
    }
}
