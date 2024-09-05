//
//  CityHistoryData.swift
//  New_Weather
//
//  Created by Егор Лукин on 05.08.2024.
//

import Foundation
class CityHistoryManager{
    static let shared = CityHistoryManager()
    private init(){}
    
    var cityHistoryArray:[String] = []
    
    func deleteLastElementFromArray(){
        if cityHistoryArray.count > 10{
            cityHistoryArray.remove(at: 0)
        }
    }
}
