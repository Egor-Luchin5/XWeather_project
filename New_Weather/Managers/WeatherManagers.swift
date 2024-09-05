//
//  WeatherManagers.swift
//  New_Weather
//
//  Created by Егор Лукин on 30.07.2024.
//

import Foundation
class WeatherManagers{
    static let shared = WeatherManagers()
    private init(){}
    
    var forecasts:[ListForecast] = []
    
    func parseJsonWeather(city: String, completion: @escaping (WeatherData?, Error?) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=b2e6396b5ac73c155061350c136e4f8e&units=metric&lang=ru"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            if let data, let weather = try? JSONDecoder().decode(WeatherData.self, from:data){
                completion(weather, nil)
            } else {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    func parsJsonWeatherCoornidate(lat:Double,long:Double, completion: @escaping (WeatherData?,Error?) -> Void){
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&appid=b2e6396b5ac73c155061350c136e4f8e&units=metric&lang=ru"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data, let weather = try? JSONDecoder().decode(WeatherData.self, from: data){
                completion(weather,nil)
            }else {
                completion(nil,error)
            }
        }
        task.resume()
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" 
        return formatter
    }()
    
    func convertToReadableTime(unixTime: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        return dateFormatter.string(from: date)
    }
    
    
}
