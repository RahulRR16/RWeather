//
//  README.md
//  RWeather
//
//

T# RWeather App

A modern iOS weather application built with **SwiftUI** using **MVVM architecture** and **Swift Concurrency (async/await)**.

## ⚠️ Important: API Key Setup Required

To make this app work, you must add your own OpenWeatherMap API key. The app will not fetch data without it.

### Steps to Configure

1.  **Get an API Key**
    * Go to [OpenWeatherMap.org](https://openweathermap.org/api).
    * Sign up for a free account.
    * Generate a new API Key (it usually starts with `Current Weather Data`).

2.  **Add Key to Xcode**
    * Open the project in Xcode.
    * Navigate to the **`WeatherService.swift`** file
    * Locate the `apiKey`.
    * Replace the placeholder text with your actual key

3.  **Run the App**
    * Build and run (Cmd + R).
    * **Note:** If you just created a new OpenWeather account, it may take 10-15 minutes for your key to become active.

## Features
* **Real-time Weather:** Fetches current temperature, humidity, and conditions.
* **5-Day Forecast:** View upcoming weather trends.
* **Location Services:** Auto-detects your current city on launch.
* **Search:** Search for any city globally.

## Requirements
* iOS 18.2+
* Xcode 16.0+
