//
//  GetDateModel.swift
//  MealManagementApp
//
//  Created by 酒井直輝 on 2021/07/22.
//

import Foundation
class GetDateModel {
    static func getTodayDate()->String{
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .full
        formatter.dateFormat = "yyyyMMdd"
       
        formatter.locale = Locale(identifier: "ja_JP")
        let today = Date()
        
        
        return formatter.string(from: today)
    }
    static func getTimeDate()->String{
        let formatter = DateFormatter()
        formatter.timeStyle = .full
        formatter.dateStyle = .none
        formatter.dateFormat = "Hmm"
        formatter.locale = Locale(identifier: "ja_JP")
        let time = Date()
        
        return formatter.string(from: time)
    }
    static func getTodayAndTimeDate()->String{
        let formatter = DateFormatter()
        formatter.timeStyle = .full
        formatter.dateStyle = .none
        formatter.dateFormat = "yyyyMMddHHmmss"
        formatter.locale = Locale(identifier: "ja_JP")
        let time = Date()
        
        return formatter.string(from: time)
    }
}
