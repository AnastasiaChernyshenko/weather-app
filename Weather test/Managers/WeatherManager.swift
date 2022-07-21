//
//  WeatherManager.swift
//  Weather test
//
//  Created by Anastasia on 19.07.2022.
//

import Foundation
import CoreLocation

final class WeatherManager {
    private let baseUrl = "https://api.openweathermap.org/"
    private let apiKey = "ccf700be67d0aeb3cd9383ecd1b6672a"
 
    func getDetailCityWeather(lat: CLLocationDegrees, lon: CLLocationDegrees) async throws -> WeatherResponse {
        guard var url  = URL(string: "\(baseUrl)data/2.5/onecall?") else { fatalError() }
        var urlComponents = URLComponents(string: url.absoluteString)!
        urlComponents.queryItems = [
              URLQueryItem(name: "lat", value: "\(lat)"),
              URLQueryItem(name: "lon", value: "\(lon)"),
              URLQueryItem(name: "exclude", value: "minutely"),
              URLQueryItem(name: "appid", value: apiKey),
              URLQueryItem(name: "units", value: "metric")
          ]
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        url = urlComponents.url!
        let urlRequest = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)
        return decodedData
    }
}
