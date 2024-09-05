//
//  ForecastViewController.swift
//  New_Weather
//
//  Created by Егор Лукин on 02.08.2024.
//

import UIKit

class ForecastViewController: UIViewController, UITableViewDataSource{
    var forecasts: [ListForecast] = []
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.rowHeight = 90
        
        //MARK: - Notification's
        NotificationCenter.default.addObserver(self, selector: #selector(fetchWeatherData(_:)), name: NSNotification.Name("SelectedCity"), object: nil)
    }
    
    @IBAction func closeControllerButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func formatDate(dateString: String) -> String {
        // Формат даты, получаемой из API
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Пример формата, может отличаться
        // Формат для вывода: "dd HH:mm"
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd HH:mm"
        // Конвертируем строку в дату, а затем обратно в строку с новым форматом
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return "Ошибка преобразования даты"
        }
    }
    
    @objc func fetchWeatherData(_ notification: Notification) {
        cityLabel.text = notification.object as? String
        activityIndicatorIsActive()

        ForecastWeatherManager.shared.fetchWeatherData( city: notification.object as! String) { [weak self] forecastweather, error in
            if let forecastweather = forecastweather {
                self!.forecasts = forecastweather.list
                DispatchQueue.main.async { [self] in
                    self!.tableView.reloadData()
                    self!.activityIndicatorIsNotActive()
                }
            }
        }
    }
    
    //MARK: -activityIndicator
    private func activityIndicatorIsActive(){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    private func activityIndicatorIsNotActive(){
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
    
    //MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"CellTableViewCell", for:indexPath) as! CellTableViewCell
        let forecast = forecasts[indexPath.row]
        let formattedDate = formatDate(dateString: forecast.dtTxt)
        //forecast.weather.description
        
        //MARK: - Switch
        switch forecast.weather[0].description.rawValue{
        case "ясно":
            cell.imageForecastImageView.image = UIImage(named: "ясно")
        case "небольшой проливной дождь":
            cell.imageForecastImageView.image = UIImage(named: "небольшойдождь")
        case "пасмурно":
            cell.imageForecastImageView.image = UIImage(named: "пасмурно1")
        case "переменная облачность":
            cell.imageForecastImageView.image = UIImage(named: "переменнаяоблачность")
        case "небольшая облачность":
            cell.imageForecastImageView.image = UIImage(named: "небольшаяоблачность")
        case "небольшой дождь":
            cell.imageForecastImageView.image = UIImage(named: "небольшойдождь")
        case "облачно с прояснениями":
            cell.imageForecastImageView.image = UIImage(named: "небольшаяоблачность")
        case "дождь":
            cell.imageForecastImageView.image = UIImage(named: "дождь")
        default:
            cell.imageForecastImageView.image = UIImage(named: "not-found-ico")
        }
        
        cell.timeForecastLabel.text = "\(formattedDate)"
        cell.degreeForecastLabel.text = "\(Int(forecast.main.temp)) °C"
        return cell
    }
}
