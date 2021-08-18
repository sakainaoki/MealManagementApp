//
//  SettingViewController.swift
//  MealManagementApp
//
//  Created by 酒井直輝 on 2021/07/12.
//

import UIKit
import Firebase
import FirebaseFirestore
protocol SettingToSearchDelegate {
    func settingToSearch(food:FoodsModel)
}

class SettingViewController: UIViewController {
    
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var carbLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var intakeTextField: UITextField!
   
    
    
    var pickerView = UIPickerView()
    let intakes = ["10","20","30","40","50","60","70","80","90","100","110","120","130","140","150","160","170","180","190","200","210","220","230","240","250","260","270","280","290","300"]
    
    var foodName = String()
    var carb = String()
    var protein = String()
    var fat = String()
    var kcal = String()
    
    var num = Double()
    var carbNum = Double()
    var proteinNum = Double()
    var fatNum = Double()
    var kcalNum = Double()
    
    var delegate:SettingToSearchDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        intakeTextField.inputView = pickerView
        setPFCData()
    }
    
    func setPFCData(){
        foodNameLabel.text = foodName
        carbLabel.text = carb
        proteinLabel.text = protein
        fatLabel.text = fat
        kcalLabel.text = kcal
    }
    
    func FoodsCalculation(){
        num = Double(intakeTextField.text!)!
        carbNum = floor(Double(carbLabel.text!)! / 100.0 * num)
        proteinNum = floor(Double(proteinLabel.text!)! / 100.0 * num)
        fatNum = floor(Double(fatLabel.text!)! / 100.0 * num)
        kcalNum = floor(Double(kcalLabel.text!)! / 100.0 * num)
    }
    
  
   
    
    
    @IBAction func registerButton(_ sender: Any) {
        FoodsCalculation()
        let foodsModel = FoodsModel(foodName: foodName, carb: String(carbNum), protein: String(proteinNum), fat: String(fatNum), kcal: String(kcalNum))
        delegate?.settingToSearch(food: foodsModel)
        
        
        //        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        self.navigationController?.popToViewController(navigationController!.viewControllers[1], animated: true)
    }
}


extension SettingViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return intakes.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        intakeTextField.text = intakes[row]
        intakeTextField.resignFirstResponder()
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return intakes[row]
    }
}
