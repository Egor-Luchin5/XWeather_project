//
//  RecentlyViewController.swift
//  New_Weather
//
//  Created by Егор Лукин on 05.08.2024.
//

import UIKit

struct SelectedCity {
    let cityName: String
}

class RecentlyViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var timer = Timer()
    
    @IBOutlet weak var informationAboutHistoryCityLabel: UILabel!
    @IBOutlet weak var tableview: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        DispatchQueue.main.async {
            self.tableview.reloadData()
        }
        startBlinking()
    }
    
    @IBAction func closePressedButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func startBlinking() {
            timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
                UIView.animate(withDuration: 0.8) {
                    self.informationAboutHistoryCityLabel.alpha = self.informationAboutHistoryCityLabel.alpha == 0 ? 1 : 0
                }
            }
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CityHistoryManager.shared.cityHistoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentlyTableViewCell", for: indexPath) as! RecentlyTableViewCell
        cell.recentlyCityLabel.text = CityHistoryManager.shared.cityHistoryArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCity = CityHistoryManager.shared.cityHistoryArray[indexPath.row]
        let cityData = SelectedCity(cityName: selectedCity)
        
        NotificationCenter.default.post(name: Notification.Name("CityTextField"), object: cityData.cityName, userInfo: nil )

        dismiss(animated: true, completion: nil)
    }
}
