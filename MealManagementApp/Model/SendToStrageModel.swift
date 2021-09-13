//
//  SendToDBModel.swift
//  MealManagementApp
//
//  Created by 酒井直輝 on 2021/07/28.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseAuth
class SendToStrageModel{
    init(){
        
    }
    static func sendMealImageData(data:Data, time:String){
        print(time)
        let year = UserDefaults.standard.object(forKey: "yearNum") as! String
        let month = UserDefaults.standard.object(forKey: "monthNum") as! String
        let day = UserDefaults.standard.object(forKey: "dayNum") as! String
        let date = year + month + day
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let image = UIImage(data: data)
        let mealImageData = image?.jpegData(compressionQuality: 0.1)
        let imageRef = Storage.storage().reference().child("mealImage").child(uid).child(date).child("\(uid + time + date)")
        imageRef.putData(mealImageData!, metadata: nil) { StorageMetadata, Error in
            if Error != nil {
                print("storageへの保存に失敗しました。",Error.debugDescription)
                return
            }
            imageRef.downloadURL { URL, Error in
                if Error != nil {
                    print("urlのダウンロードに失敗しました。",Error.debugDescription)
                    return
                }
            }
        }
    }
}
