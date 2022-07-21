//
//  WeatherModel.swift
//  Weather test
//
//  Created by Anastasia on 21.07.2022.
//

struct WeatherResponse: Decodable {
    let hourly: [HourlyResponse]
    let daily: [DailyResponse]
}

struct HourlyResponse: Decodable {
    let dt: Int
    let temp: Double
    let weather: [Weather]
}

struct DailyResponse: Decodable {
    let dt: Int
    let temp: Temp
    let weather: [Weather]
    let humidity: Double
    let windSpeed: Double
    
    enum CodingKeys: String, CodingKey {
        case dt
        case temp
        case weather
        case humidity
        case windSpeed = "wind_speed"
    }
}

struct Weather: Decodable {
    let icon: String
}

struct Temp: Decodable {
    let min: Double
    let max: Double
}
