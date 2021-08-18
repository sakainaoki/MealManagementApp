//
//  UserModel.swift
//  MealManagementApp
//
//  Created by 酒井直輝 on 2021/07/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
struct User {
    
    let userName:String
    let email:String
    
    init(dic: [String: Any]){
        self.userName = dic["userName"] as! String
        self.email = dic["email"] as! String
    }
}
