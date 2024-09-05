//
//  ForecastWeatherManager.swift
//  New_Weather
//
//  Created by Егор Лукин on 09.08.2024.
//

import Foundation
class ForecastWeatherManager{
    static let shared = ForecastWeatherManager()
    private init(){}
    
    func fetchWeatherData(city:String, completion: @escaping(ForecastData?, Error?)-> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=b2e6396b5ac73c155061350c136e4f8e&units=metric&lang=ru"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  error == nil else {
                print(error?.localizedDescription
                      ?? "Ошибка при загрузке данных")
                return
            }
            
            do {
                let weatherData = try JSONDecoder().decode(ForecastData.self, from: data)
                completion(weatherData,nil)

            } catch {
                completion(nil, error)

            }
        }.resume()
    }    
}
