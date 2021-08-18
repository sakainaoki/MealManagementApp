//
//  ManualInputViewController.swift
//  MealManagementApp
//
//  Created by 酒井直輝 on 2021/08/10.
//

import UIKit
import Firebase
import EMAlertController

protocol AlertToSearchDelegate {
    func tappedInputButton()
}
class ManualInputViewController: UIViewController {

    @IBOutlet weak var foodNameTextField: UITextField!
    @IBOutlet weak var cTextField: UITextField!
    @IBOutlet weak var pTextField: UITextField!
    @IBOutlet weak var fTextField: UITextField!
    @IBOutlet weak var kcalTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    var alertSystem = AlertSystem()
    var delegate:AlertToSearchDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodNameTextField.delegate = self
        cTextField.delegate = self
        pTextField.delegate = self
        fTextField.delegate = self
        kcalTextField.delegate = self
        registerButtonIsEnabled()
        registerButton.layer.cornerRadius = 15
       
    }
    
    
    func registerButtonIsEnabled(){
        if cTextField.text?.isEmpty == true || pTextField.text?.isEmpty == true || fTextField.text?.isEmpty == true || kcalTextField.text?.isEmpty == true || foodNameTextField.text?.isEmpty == true {
            registerButton.isEnabled = false
            registerButton.backgroundColor = UIColor.rgb(red: 169, green: 169, blue: 169)
        }else{
            registerButton.isEnabled = true
            registerButton.backgroundColor = UIColor.rgb(red: 48, green: 209, blue: 88)
        }
    }
    
    
    func calc(){
        let cKcal = Double(cTextField.text!)! * 4.0
        let pKcal = Double(pTextField.text!)! * 4.0
        let fKcal = Double(fTextField.text!)! * 9.0
        let totalKcal = (floor(cKcal + pKcal + fKcal))
        print(cKcal)
        print(pKcal)
        print(fKcal)
        print(totalKcal)
        kcalTextField.text = String(totalKcal)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    private func sendToFirestore(){
        guard let foodName = foodNameTextField.text else {return}
        guard let c = cTextField.text else {return}
        guard let p = pTextField.text else {return}
        guard let f = fTextField.text else {return}
        guard let kcal = kcalTextField.text else {return}
        
        let docData = ["foodName":foodName,
                       "carb":c,
                       "protein":p,
                       "fat":f,
                       "kcal":kcal
        ]
        Firestore.firestore().collection("foods").document().setData(docData) { Error in
            if Error != nil{
                print("データベースへの保存に失敗しました。")
                return
            }else{
                print("データベースへの保存に成功しました。")
                self.foodNameTextField.text = ""
                self.cTextField.text = ""
                self.pTextField.text = ""
                self.fTextField.text = ""
                self.kcalTextField.text = ""
                self.navigationController?.popViewController(animated: true)
                self.delegate?.tappedInputButton()
            }
        }
        
    }

    @IBAction func registerButton(_ sender: Any) {
        sendToFirestore()
        
    }
    
}


extension ManualInputViewController:UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        registerButtonIsEnabled()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}
