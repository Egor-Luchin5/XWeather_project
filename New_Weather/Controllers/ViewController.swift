//
//  ViewController.swift
//  New_Weather
//
//  Created by Егор Лукин on 27.07.2024.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate{
    static let shared = ViewController()
    let alertSearchCityView = AlertSearchCityView.instanceFromNib()
    let locationManager = CLLocationManager()
    
    //MARK: Outlet's
    @IBOutlet weak var funnyGifImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var cloudsLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var generalInformationAboutWeatherLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var backgroundTimeImageView: UIImageView!
    @IBOutlet weak var generalTemperatureLabel: UILabel!
    @IBOutlet weak var detailCityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertSearchCityView.frame = CGRect(x: Int(view.frame.width)/2 - Int(390 / 2), y: 0 - 390, width: 390, height: 160)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //MARK: - Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(closeAlert), name: NSNotification.Name("closeAlert"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cityfromTextField(_:)), name: NSNotification.Name("CityTextField"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadImageBackgroundTime), name: UIApplication.willEnterForegroundNotification, object: nil)
        loadImageBackgroundTime()
    }
    
    @objc func loadImageBackgroundTime(){
        let date = Date()
        let calendar = Calendar.current
        let timeString = calendar.component(.hour, from: date)
        switch timeString {
        case 5...7:
            self.backgroundTimeImageView.image = UIImage(named: "sunrise-background")
        case 8...17:
            self.backgroundTimeImageView.image = UIImage(named: "day-background")
        case 18...20:
            self.backgroundTimeImageView.image = UIImage(named: "sunset-background")
        case 21...23, 0...4:
            self.backgroundTimeImageView.image = UIImage(named: "night-background")
        default:
            print("Не удалось определить время суток")
        }
    }
    
    @objc func cityfromTextField(_ notification: Notification){
        print(notification.object as! String)
        detailCityLabel.text = notification.object as? String
        activityIndicatorIsActive()
        
        WeatherManagers.shared.parseJsonWeather(city: notification.object as! String) {    [weak self]  weather, error in
            guard let self = self else {return}
            if let weather = weather {
                // Обновляем UI с полученными данными
                DispatchQueue.main.async{
                    self.generalTemperatureLabel.text = "\(Int(weather.main.temp))°"
                    self.minTempLabel.text = "\(Int(weather.main.tempMin))°"
                    self.maxTempLabel.text = "\(Int(weather.main.tempMax))°"
                    self.feelsLikeLabel.text = "\(Int(weather.main.feelsLike))°"
                    self.windLabel.text = "\(Int(weather.wind.speed)) м/с"
                    self.pressureLabel.text = "\(Int(weather.main.pressure)) Па"
                    self.humidityLabel.text = "\(Int(weather.main.humidity)) %"
                    self.visibilityLabel.text = "\(Int(weather.visibility)) км"
                    self.cloudsLabel.text = "\(Int(weather.clouds.all)) %"
                    
                    //sunrise and sunset
                    self.sunriseLabel.text = WeatherManagers.shared.convertToReadableTime(unixTime: TimeInterval(weather.sys.sunrise))
                    self.sunsetLabel.text = WeatherManagers.shared.convertToReadableTime(unixTime: TimeInterval(weather.sys.sunset))
                    
                    print(weather.weather[0].description)
                    
                    //MARK: - Switch
                    switch weather.weather[0].description {
                    case "ясно":
                        self.weatherImage.image = UIImage(named: "ясно")
                        self.generalInformationAboutWeatherLabel.text = "Сейчас ясно"
                    case "пасмурно":
                        self.weatherImage.image = UIImage(named: "пасмурно1")
                        self.generalInformationAboutWeatherLabel.text = "Сейчас пасмурно"
                    case "переменная облачность":
                        self.weatherImage.image = UIImage(named: "переменнаяоблачность")
                        self.generalInformationAboutWeatherLabel.text = "Сейчас переменная облачность"
                    case "небольшая облачность":
                        self.weatherImage.image = UIImage(named: "небольшаяоблачность")
                        self.generalInformationAboutWeatherLabel.text = "Сейчас небольшая облачность"
                    case "небольшой дождь":
                        self.weatherImage.image = UIImage(named: "небольшойдождь")
                        self.generalInformationAboutWeatherLabel.text = "Сейчас идёт небольшой дождь"
                    case "небольшой проливной дождь":
                        self.weatherImage.image = UIImage(named: "небольшойдождь")
                        self.generalInformationAboutWeatherLabel.text = "Сейчас идёт небольшой проливной дождь"
                    case "облачно с прояснениями":
                        self.weatherImage.image = UIImage(named: "небольшаяоблачность")
                        self.generalInformationAboutWeatherLabel.text = "Сейчас облачно с прояснениями"
                    case "дождь":
                        self.weatherImage.image = UIImage(named: "дождь")
                        self.generalInformationAboutWeatherLabel.text = "Сейчас идёт дождь"
                    default:
                        self.weatherImage.image = UIImage(named: "not-found-ico")
                    }
                    
                    self.activityIndicatorIsNotActive()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(0.5)), execute: DispatchWorkItem(block: {
                        self.addOrRemoveCity()
                    }))
                }
            } else {
                // Обрабатываем ошибку
                DispatchQueue.main.async{
                    self.defaultSettingsWeather(error: "Город не найден или отсутствует интернет")
                }
            }
        }
        
    }
    
    //MARK: - @IBAction's
    
    @IBAction func openForecastPressedButton(_ sender: UIButton) {
        guard let forecastController = self.storyboard?.instantiateViewController(withIdentifier: "ForecastViewController") as? ForecastViewController else {return}
        present(forecastController, animated: true)
        NotificationCenter.default.post(name: NSNotification.Name("SelectedCity"), object: detailCityLabel.text)
    }
    
    @IBAction func addCityPressedButton(_ sender: UIButton) {
        addAlertSearchCity()
        
    }
    
    @IBAction func openHistoryCityPressedButton(_ sender: UIButton) {
        guard let historyCityController = self.storyboard?.instantiateViewController(withIdentifier: "RecentlyViewController") as? RecentlyViewController else {return}
        CityHistoryManager.shared.cityHistoryArray = (UserDefaults.standard.array(forKey: "SavedArrayHistoryCity") as? [String] ?? [])
        self.present(historyCityController, animated: true)
    }
    
    @IBAction func myLocationPressedButton(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
        
        addOrRemoveCity()
    }
    
    private func addOrRemoveCity(){
        if detailCityLabel.text == "Ваш город не найден"{
            print("No")
        } else {
            CityHistoryManager.shared.cityHistoryArray.contains(detailCityLabel.text!) ? print("уже есть") : CityHistoryManager.shared.cityHistoryArray.append(detailCityLabel.text!)
            CityHistoryManager.shared.deleteLastElementFromArray()
            UserDefaults.standard.set(CityHistoryManager.shared.cityHistoryArray, forKey: "SavedArrayHistoryCity")
        }

    }
    
    private func AddErrorAlert(){
        //Создаем Alert
        let alert = UIAlertController(title: "Ошибка", message: "Убедитесь в правильности города или присутствии интернета", preferredStyle: .alert)
        //Создаем кнопку подтверждения
        let OkAlertAction = UIAlertAction(title: "Окей", style: .default) { _ in
            print("окей")
        }
        alert.addAction(OkAlertAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func AddNotFindLocationAlert(){
        let alert = UIAlertController(title: "Локация не найдена", message: "Ваша локация была не найдена. Проверьте службы геолокаций и присутствие интернета", preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "Настройки", style: .default) { _ in
            if let url = URL(string: "App-Prefs:root=LOCATION_SERVICES"){
                UIApplication.shared.open(url,options: [:],completionHandler: nil)
            }
        }
        let cancelAlertAction = UIAlertAction(title: "Назад", style: .default) { _ in
            print("cancel")
        }
        alert.addAction(okAlertAction)
        alert.addAction(cancelAlertAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Moves for Custom Alert
    private func addAlertSearchCity(){
        UIView.animate(withDuration: 0.5) {
            self.view.addSubview(self.alertSearchCityView)
            self.alertSearchCityView.CityTextField.becomeFirstResponder()
            self.alertSearchCityView.frame.origin.y += 440
        }
    }
    
    @objc func closeAlert(){
        UIView.animate(withDuration: 0.5) {
            self.alertSearchCityView.frame.origin.y -= 440
            self.alertSearchCityView.alpha = 0
        } completion: { _ in
            self.alertSearchCityView.removeFromSuperview()
            self.alertSearchCityView.alpha = 1
        }
    }
    
    //MARK: - activityIndicator
    private func activityIndicatorIsActive(){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    private func activityIndicatorIsNotActive(){
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        activityIndicatorIsActive()
        let location: CLLocationCoordinate2D = manager.location!.coordinate
        
        guard let currentLocation = locations.last else {return}
        
        //        if currentLocation.horizontalAccuracy > 0 {
        //            locationManager.stopUpdatingLocation()
        
        let coordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
        
        WeatherManagers.shared.parsJsonWeatherCoornidate(lat: coordinate.latitude, long: coordinate.longitude) { weather, error in
            if let weather = weather {
                // Обновляем UI с полученными данными
                DispatchQueue.main.async{
                    self.detailCityLabel.text = "\(weather.name)"
                    self.generalTemperatureLabel.text = "\(Int(weather.main.temp))°"
                    self.minTempLabel.text = "\(Int(weather.main.tempMin))°"
                    self.maxTempLabel.text = "\(Int(weather.main.tempMax))°"
                    self.feelsLikeLabel.text = "\(Int(weather.main.feelsLike))°"
                    self.windLabel.text = "\(Int(weather.wind.speed)) м/с"
                    self.pressureLabel.text = "\(Int(weather.main.pressure)) Па"
                    self.humidityLabel.text = "\(Int(weather.main.humidity)) %"
                    self.visibilityLabel.text = "\(Int(weather.visibility)) км"
                    self.cloudsLabel.text = "\(Int(weather.clouds.all)) %"
                    
                    //sunrise and sunset
                    self.sunriseLabel.text = WeatherManagers.shared.convertToReadableTime(unixTime: TimeInterval(weather.sys.sunrise))
                    self.sunsetLabel.text = WeatherManagers.shared.convertToReadableTime(unixTime: TimeInterval(weather.sys.sunset))
                    
                    //MARK: - Switch
                    switch weather.weather[0].description {
                    case "ясно":
                        self.weatherImage.image = UIImage(named: "ясно")
                        self.generalInformationAboutWeatherLabel.text = "Сейчас ясно"
                    case "пасмурно":
                        self.weatherImage.image = UIImage(named: "пасмурно1")
                        self.generalInformationAboutWeatherLabel.text = "Сейчас пасмурно"
                    case "переменная облачность":
                        self.weatherImage.image = UIImage(named: "переменнаяоблачность")
                        self.generalInformationAboutWeatherLabel.text = "Сейчас переменная облачность"
                    case "небольшая облачность":
                        self.weatherImage.image = UIImage(named: "небольшаяоблачность")
                        self.generalInformationAboutWeatherLabel.text = "Сейчас небольшая облачность"
                    case "небольшой дождь":
                        self.weatherImage.image = UIImage(named: "небольшойдождь")
                        self.generalInformationAboutWeatherLabel.text = "Сейчас идёт небольшой дождь"
                    case "облачно с прояснениями":
                        self.weatherImage.image = UIImage(named: "небольшаяоблачность")
                        self.generalInformationAboutWeatherLabel.text = "Сейчас облачно с прояснениями"
                    case "небольшой проливной дождь":
                        self.weatherImage.image = UIImage(named: "небольшойдождь")
                        self.generalInformationAboutWeatherLabel.text = "Сейчас идёт небольшой проливной дождь"
                    case "дождь":
                        self.weatherImage.image = UIImage(named: "дождь")
                        self.generalInformationAboutWeatherLabel.text = "Сейчас идёт дождь"
                    default:
                        self.weatherImage.image = UIImage(named: "not-found-ico")
                    }
                    self.locationManager.stopUpdatingLocation()
                    self.activityIndicatorIsNotActive()
                    
                }
            } else {
                // Обрабатываем ошибку
                DispatchQueue.main.async{
                    self.defaultSettingsWeather(error: "Ваше местонахождение не найдено или отсутствует интернет")
                }
            }
        }
        
    }
    
    private func defaultSettingsWeather(error:String){
        self.generalInformationAboutWeatherLabel.text = "\(error)"
        self.generalTemperatureLabel.text = "\(0)°"
        self.detailCityLabel.text = "Ваш город не найден"
        self.minTempLabel.text = "\(0)°"
        self.maxTempLabel.text = "\(0)°"
        self.weatherImage.loadGif(name: "john-travolta")
        self.feelsLikeLabel.text = "°"
        self.windLabel.text = "м/с"
        self.pressureLabel.text = "Па"
        self.humidityLabel.text = "%"
        self.visibilityLabel.text = "км"
        self.cloudsLabel.text = "%"
        self.sunriseLabel.text = "Восход"
        self.sunsetLabel.text = "Закат"
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        AddNotFindLocationAlert()
    }
}
