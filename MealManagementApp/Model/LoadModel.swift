//
//  LoadModel.swift
//  MealManagementApp
//
//  Created by 酒井直輝 on 2021/08/08.
//

import Foundation
import Firebase
protocol GetDataProtocol {
    func getData(dataArray:[PersonalData])
}
protocol GetNotReadProtocol {
    func getNotReadMessages(notReadMessages:[MessagesModel])
}
class LoadModel{
    var personalDataArray = [PersonalData]()
    var getDataProtocol:GetDataProtocol?
    var getNotReadProtocol:GetNotReadProtocol?
    var notReadMessages = [MessagesModel]()
    func loadMyRecordData(userID:String,year:String,month:String){
        Firestore.firestore().collection("users").document(userID).collection("bodyWeights").document(year).collection(month).addSnapshotListener { SnapshotMetadata, Error in
            self.personalDataArray = []
            if Error != nil{
                print("体重の取得に失敗しました。",Error.debugDescription)
                return
            }
            if let snapShotDoc = SnapshotMetadata?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    if let weight = data["bodyWeight"] as? String,let date = data["date"] as? String{
                        let newPersonalData = PersonalData(weight: weight, date: date)
                        self.personalDataArray.append(newPersonalData)
                    }
                }
            }
            self.getDataProtocol?.getData(dataArray: self.personalDataArray)
        }
    }
    
    func loadMessageFromFirestore(){
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).collection("messages").order(by: "timeStamp").addSnapshotListener {
            SnapshotMetadata, Error in
            self.notReadMessages = []
            if Error != nil{
                print("messageの取得に失敗しました。")
                return
            }
            if let snapShotDoc = SnapshotMetadata?.documents {
                for doc in snapShotDoc {
                    let data = doc.data()
                    if let sender = data["uid"] as? String,let message = data["message"] as? String,let date = data["date"] as? String,let time = data["time"] as? String,let read = data["read"] as? Bool,let dayAndTime = data["dayAndTime"] as? String{
                        let message = MessagesModel(uid: sender, message: message, date: date, time: time, read: read, dayAndTime: dayAndTime)
                        if message.read == false && message.uid != uid{
                            self.notReadMessages.append(message)
                        }
                    }
                }
                self.getNotReadProtocol?.getNotReadMessages(notReadMessages: self.notReadMessages)
            }
        }
    }
    
    func loadTargetWeight(userUid:String){
        Firestore.firestore().collection("users").document(userUid).collection("targetWeight").addSnapshotListener { SnapshotMetadata, Error in
            if Error != nil{
                print("データの取得に失敗しました。",Error.debugDescription)
                return
            }
            if let snapShotDoc = SnapshotMetadata?.documents {
                for doc in snapShotDoc {
                    let data = doc.data()
                    if let targetWeight = data["targetWeight"] as? String{
                        UserDefaults.standard.setValue(targetWeight, forKey: "targetWeight")
                    }
                    print("目標体重データの取得に成功しました。")
                    
                }
            }
        }
    }
}
