////
////  ContentView.swift
////  RWeather
////
////  Created by Rahul on 29/01/2025.
////
//
import SwiftUI

struct WeatherHomeView: View {
    // @StateObject ensures the ViewModel stays alive during UI updates.
    @StateObject private var viewModel = WeatherViewModel()
    
    // Tracks if the search bar text field is currently active (keyboard open).
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. BACKGROUND LAYER
                GeometryReader { _ in
                    Image("bgImg")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .opacity(0.6)
                }
                .ignoresSafeArea(.keyboard)
                .onTapGesture {
                    isSearchFocused = false // Tap anywhere on background to dismiss keyboard
                }
                
                // 2. MAIN CONTENT LAYER
                VStack(spacing: 0) {
                    VStack(spacing: 15) {
                        // App Title
                        Text("RWeather")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .padding(.top, 10)
                        
                        // The Search Bar Component
                        searchBar
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .background(Color.clear)
                    
                    // --- SCROLLABLE CONTENT (Weather Card & Buttons) ---
                    ScrollView {
                        VStack(spacing: 30) {
                            if let weather = viewModel.weather {
                                WeatherDetailsView(weatherData: weather)
                                    .transition(.scale.combined(with: .opacity))
                            } else if !viewModel.isLoading {
                                placeholderView // "Enter a city to start" text
                            }
                            
                            // Logic: Show "See 5-Day Forecast" button only if we have data
                            if !viewModel.forecast.isEmpty, let weather = viewModel.weather {
                                NavigationLink(destination: ForecastView(forecast: viewModel.forecast, weather: weather)) {
                                    Text("See 5-Day Forecast")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: 220)
                                        .padding()
                                        .gradientButtonStyle()
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                            }
                        }
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity)
                    }
                    .scrollIndicators(.hidden) // Hides the side scrollbar
                    .onTapGesture {
                        isSearchFocused = false // Dismiss keyboard if scrolling area is tapped
                    }
                }
                
                // 3. LOADING OVERLAY
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.6).edgesIgnoringSafeArea(.all)
                        VStack(spacing: 15) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text("Loading...")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .zIndex(2.0) // Force this view to be on top
                }
            }
            // Standard iOS gesture to dismiss keyboard when scrolling
            .scrollDismissesKeyboard(.interactively)
            .navigationBarHidden(true)
            
        }
        // GLOBAL ERROR ALERT
        .alert("Oops!", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        }
        // ON APPEAR: Logic to auto-load location when app starts
        .onAppear {
            if viewModel.weather == nil {
                viewModel.requestLocation()
            }
        }
    }
    
    // MARK: - Components (Subviews)
    
    // The Search Bar UI
    var searchBar: some View {
        HStack {
            // Location Button (Circle Icon)
            Button(action: {
                isSearchFocused = false
                viewModel.requestLocation()
            }) {
                Image(systemName: "location.fill")
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            
            // Text Field Area
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.6))
                
                TextField("", text: $viewModel.searchText)
                // Uses our custom extension to make placeholder text white/transparent
                    .placeholder(when: viewModel.searchText.isEmpty) {
                        Text("Search City...").foregroundColor(.white.opacity(0.6))
                    }
                    .foregroundColor(.white)
                    .focused($isSearchFocused) // Links to the keyboard state
                    .submitLabel(.search) // Changes keyboard "Return" to "Search"
                    .onSubmit { viewModel.searchCity() }
                
                // "X" button to clear text
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(10)
            .background(Material.ultraThin)
            .cornerRadius(10)
            
            // "Go" Button
            Button("Go") {
                isSearchFocused = false
                viewModel.searchCity()
            }
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .gradientButtonStyle()
            .cornerRadius(10)
        }
    }
    
    // Simple placeholder when no city is selected
    var placeholderView: some View {
        VStack(spacing: 15) {
            Spacer(minLength: 50)
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 80))
                .symbolRenderingMode(.multicolor)
                .shadow(radius: 10)
            Text("Enter a city to start")
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - Weather Card View
struct WeatherDetailsView: View {
    let weatherData: WeatherData
    
    var body: some View {
        VStack(spacing: 15) {
            // City Name
            Text(weatherData.name)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Weather Icon
            if let weather = weatherData.weather.first {
                Image(systemName: WeatherHelper.getWeatherIcon(for: weather.icon))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .symbolRenderingMode(.multicolor)
                    .shadow(radius: 5)
                
                Text(weather.description.capitalized)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            // Temperature (formatted as Int to remove decimals)
            Text("\(Int(weatherData.main.temp))°C")
                .font(.system(size: 70, weight: .light))
                .foregroundColor(.white)
            
            // Stats Row (Humidity, etc)
            HStack(spacing: 20) {
                HStack {
                    Image(systemName: "drop.fill")
                    Text("\(weatherData.main.humidity)%")
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
            }
        }
        .padding(25)
        .frame(width: 300)
        .background(Color.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}

// Extension to allow custom colored placeholders (standard SwiftUI placeholders are always gray)
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder()
                .opacity(shouldShow ? 1 : 0)
                .allowsHitTesting(false) // Allows tap to pass through text to the field below
            self
        }
    }
}
