//
//  TabViewController.swift
//  MealManagementApp
//
//  Created by 酒井直輝 on 2021/07/23.
//

import UIKit
import Firebase
class TabViewController: UITabBarController {
    let loadModel = LoadModel()
    var notReadMessages = [MessagesModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = .cyan
        UITabBar.appearance().barTintColor = .darkGray
        UITabBar.appearance().unselectedItemTintColor = .white
        loadModel.getNotReadProtocol = self
        loadModel.loadMessageFromFirestore()
        // Do any additional setup after loading the view.
    }
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        tabBar.items?[1].badgeValue = nil
        guard let uid = Auth.auth().currentUser?.uid else {return}
        for message in notReadMessages {
            let chageRead = true
            let dayAndTime = message.dayAndTime
            Firestore.firestore().collection("users").document(uid).collection("messages").document(dayAndTime).updateData(["read":chageRead]) { Error in
                if Error != nil{
                    print("readの更新に失敗しました。",Error.debugDescription)
                    return
                }
            }
        }
    }
    
 
    
}
extension TabViewController:GetNotReadProtocol{
    func getNotReadMessages(notReadMessages: [MessagesModel]) {
        if notReadMessages.count != 0 {
            tabBar.items?[1].badgeValue = String(notReadMessages.count)
            self.notReadMessages = notReadMessages
        }
        
    }
    
    
    
    
}
