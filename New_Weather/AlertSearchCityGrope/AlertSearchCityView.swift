//
//  AlertSearchCityView.swift
//  New_Weather
//
//  Created by Егор Лукин on 28.07.2024.
//

import Foundation
import UIKit

class AlertSearchCityView:UIView{
    @IBOutlet weak var CityTextField: UITextField!{
        didSet{
            CityTextField.delegate = self
        }
    }
    
    static func instanceFromNib() -> AlertSearchCityView{
        return UINib(nibName: "AlertSearchCityView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AlertSearchCityView
    }
    
    //MARK: - @IBAction's
    
    @IBAction func cancelPressedButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("closeAlert"), object: nil)
        HideKeyBoard()
    }
    
    @IBAction func SearchPressedButton(_ sender: UIButton) {
        if CityTextField.text == "Город" || CityTextField.text == "City"{
            CityTextField.text = ""
        }
        NotificationCenter.default.post(name: NSNotification.Name("CityTextField"), object: CityTextField.text?.trimmingCharacters(in: .whitespaces))
        NotificationCenter.default.post(name: NSNotification.Name("closeAlert"), object: nil)
    }
    
}

//MARK: - extensions

extension AlertSearchCityView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.HideKeyBoard()
        return true
    }
    
    func HideKeyBoard(){
        CityTextField.resignFirstResponder()
    }
}
