//
//  LoadPFCModel.swift
//  MealManagementApp
//
//  Created by 酒井直輝 on 2021/08/10.
//

import Foundation
import Firebase
class LoadPFCModel{
    func loadPFCFromFirestore(userUid:String,aimCarbLabel:UILabel,aimProteinLabel:UILabel,aimFatLabel:UILabel,aimKcalLabel:UILabel){
        Firestore.firestore().collection("users").document(userUid).collection("PFC").document("targetPFC").addSnapshotListener { SnapshotMetadata, Error in
            if Error != nil{
                print("PFCの取得に失敗しました。",Error.debugDescription)
                return
            }
            if let data = SnapshotMetadata?.data(){
                if let carb = data["carb"] as? String,let protein = data["protein"] as? String,let fat = data["fat"] as? String,let kcal = data["kcal"] as? String{
                    aimCarbLabel.text = "\(carb)g"
                    aimProteinLabel.text = "\(protein)g"
                    aimFatLabel.text = "\(fat)g"
                    aimKcalLabel.text = "\(kcal)kcal"
                    
                }
            }
        }
    }
}
