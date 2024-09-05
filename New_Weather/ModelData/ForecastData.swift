//
//  ForecastData.swift
//  New_Weather
//
//  Created by Егор Лукин on 04.08.2024.
//

import Foundation

// MARK: - WeatherData
struct ForecastData: Codable {
    let cod: String
    let message, cnt: Int
    let list: [ListForecast]
    let city: CityForecast
}

// MARK: - City
struct CityForecast: Codable {
    let id: Int
    let name: String
    let coord: CoordForecast
    let country: String
    let population, timezone, sunrise, sunset: Int
}

// MARK: - Coord
struct CoordForecast: Codable {
    let lat, lon: Double
}

// MARK: - List
struct ListForecast: Codable {
    let dt: Int
    let main: MainClassForecast
    let weather: [WeatherForecast]
    let clouds: CloudsForecast
    let wind: WindForecast
    let visibility: Int
    let pop: Double
    let sys: SysForecast
    let dtTxt: String
    let rain: RainForecast?

    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, visibility, pop, sys
        case dtTxt = "dt_txt"
        case rain
    }
}

// MARK: - Clouds
struct CloudsForecast: Codable {
    let all: Int
}

// MARK: - MainClass
struct MainClassForecast: Codable {
    let temp, feelsLike, tempMin, tempMax: Double
    let pressure, seaLevel, grndLevel, humidity: Int
    let tempKf: Double

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
        case humidity
        case tempKf = "temp_kf"
    }
}

// MARK: - Rain
struct RainForecast: Codable {
    let the3H: Double

    enum CodingKeys: String, CodingKey {
        case the3H = "3h"
    }
}

// MARK: - Sys
struct SysForecast: Codable {
    let pod: PodForecast
}

enum PodForecast: String, Codable {
    case d = "d"
    case n = "n"
}

// MARK: - Weather
struct WeatherForecast: Codable {
    let id: Int
    let main: MainEnum
    let description: DescriptionForecast
    let icon: String
}

enum DescriptionForecast: String, Codable {
    case небольшаяОблачность = "небольшая облачность"
    case небольшойДождь = "небольшой дождь"
    case облачноСПрояснениями = "облачно с прояснениями"
    case пасмурно = "пасмурно"
    case переменнаяОблачность = "переменная облачность"
    case ясно = "ясно"
}

enum MainEnum: String, Codable {
    case clear = "Clear"
    case clouds = "Clouds"
    case rain = "Rain"
}

// MARK: - Wind
struct WindForecast: Codable {
    let speed: Double
    let deg: Int
    let gust: Double
}
