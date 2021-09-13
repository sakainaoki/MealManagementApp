//
//  ViewController.swift
//  MealManagementApp
//
//  Created by 酒井直輝 on 2021/07/12.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import SDWebImage

class ViewController: UIViewController {
    
    @IBOutlet weak var yearsTextField: UITextField!
    @IBOutlet weak var monthsTextField: UITextField!
    @IBOutlet weak var daysTextField: UITextField!
    @IBOutlet weak var breakfastTableView: UITableView!
    @IBOutlet weak var lunchTableView: UITableView!
    @IBOutlet weak var dinnerTableView: UITableView!
    @IBOutlet weak var snackTableView: UITableView!
    @IBOutlet weak var totalKcalLabel: UILabel!
    @IBOutlet weak var totalCarbLabel: UILabel!
    @IBOutlet weak var totalProteinLabel: UILabel!
    @IBOutlet weak var totalFatLabel: UILabel!
    @IBOutlet weak var changeDateButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var breakFastProteinLabel: UILabel!
    @IBOutlet weak var breakfastFatLabel: UILabel!
    @IBOutlet weak var breakfastCarbLabel: UILabel!
    @IBOutlet weak var breakfastKcalLabel: UILabel!
    @IBOutlet weak var lunchProteinLabel: UILabel!
    @IBOutlet weak var lunchFatLabel: UILabel!
    @IBOutlet weak var lunchCarbLabel: UILabel!
    @IBOutlet weak var lunchKcalLabel: UILabel!
    @IBOutlet weak var dinnerProteinLabel: UILabel!
    @IBOutlet weak var dinnerFatLabel: UILabel!
    @IBOutlet weak var dinnerCarbLabel: UILabel!
    @IBOutlet weak var dinnerKcalLabel: UILabel!
    @IBOutlet weak var snackProteinLabel: UILabel!
    @IBOutlet weak var snackFatLabel: UILabel!
    @IBOutlet weak var snackCarbLabel: UILabel!
    @IBOutlet weak var snackKcalLabel: UILabel!
    @IBOutlet weak var imagesUIView: UIView!
    @IBOutlet weak var mealsImageView: UIImageView!
    @IBOutlet weak var aimKcalLabel: UILabel!
    @IBOutlet weak var aimCarbLabel: UILabel!
    @IBOutlet weak var aimProteinLabel: UILabel!
    @IBOutlet weak var aimFatLabel: UILabel!
    
    
    var user:User? {
        didSet {
            print("user?.userName",user?.userName as Any)
        }
    }
    
    var breakfastArray:[FoodsModel] = []
    var lunchArray:[FoodsModel] = []
    var dinnerArray:[FoodsModel] = []
    var snackArray:[FoodsModel] = []
    
    var tag = 0
    var cellIdentifier = ""
    var yearsPickerView = UIPickerView()
    var monthsPickerView = UIPickerView()
    var daysPickerView = UIPickerView()
    var alertSystem = AlertSystem()
    let years = ["2021","2022","2023","2024","2025","2026","2027","2028","2029","2030"]
    let months = ["01","02","03","04","05","06","07","08","09","10","11","12"]
    let days1 = ["01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"]
    var time = String()
    var loadPFC = LoadPFCModel()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        breakfastTableView.delegate = self
        breakfastTableView.dataSource = self
        lunchTableView.delegate = self
        lunchTableView.dataSource = self
        dinnerTableView.delegate = self
        dinnerTableView.dataSource = self
        snackTableView.delegate = self
        snackTableView.dataSource = self
        yearsPickerView.delegate = self
        yearsPickerView.dataSource = self
        monthsPickerView.delegate = self
        monthsPickerView.dataSource = self
        daysPickerView.delegate = self
        daysPickerView.dataSource = self
        yearsTextField.delegate = self
        monthsTextField.delegate = self
        daysTextField.delegate = self
        breakfastTableView.backgroundColor = .white
        lunchTableView.backgroundColor = .white
        dinnerTableView.backgroundColor = .white
        snackTableView.backgroundColor = .white
        breakfastTableView.register(UINib(nibName: "MealsTableViewCell", bundle: nil), forCellReuseIdentifier: "breakfastCell")
        lunchTableView.register(UINib(nibName: "MealsTableViewCell", bundle: nil), forCellReuseIdentifier: "lunchCell")
        dinnerTableView.register(UINib(nibName: "MealsTableViewCell", bundle: nil), forCellReuseIdentifier: "dinnerCell")
        snackTableView.register(UINib(nibName: "MealsTableViewCell", bundle: nil), forCellReuseIdentifier: "snackCell")
        
        nextButton.layer.cornerRadius = 25
        
        yearsTextField.backgroundColor = UIColor.rgb(red: 221, green: 221, blue: 221)
        yearsTextField.layer.cornerRadius = 15
        yearsTextField.inputView = yearsPickerView
        monthsTextField.backgroundColor = UIColor.rgb(red: 221, green: 221, blue: 221)
        monthsTextField.layer.cornerRadius = 15
        monthsTextField.inputView = monthsPickerView
        daysTextField.backgroundColor = UIColor.rgb(red: 221, green: 221, blue: 221)
        daysTextField.layer.cornerRadius = 15
        daysTextField.inputView = daysPickerView
        yearsPickerView.tag = 1
        monthsPickerView.tag = 2
        daysPickerView.tag = 3
        
        let date = GetDateModel.getTodayDate()
        yearsTextField.text = String(date.prefix(4))
        daysTextField.text = String(date.suffix(2))
        let startIndex = date.index(date.startIndex, offsetBy: 4)
        let endIndex = date.index(date.startIndex, offsetBy: 6)
        let month = date[startIndex..<endIndex]
        monthsTextField.text = String(month)
        
        imagesUIView.isHidden = true
        guard let uid = Auth.auth().currentUser?.uid else {return}
        loadPFC.loadPFCFromFirestore(userUid: uid, aimCarbLabel: aimCarbLabel, aimProteinLabel: aimProteinLabel, aimFatLabel: aimFatLabel, aimKcalLabel: aimKcalLabel)
        
    }
    
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadMealsFromFirestore()
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let registerVC = segue.destination as! RegistrationViewController
        registerVC.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        imagesUIView.isHidden = true
        mealsImageView.image = UIImage(named: "image")
    }
    
    
    
    private func loadMealsFromFirestore(){
        self.breakfastArray.removeAll()
        self.lunchArray.removeAll()
        self.dinnerArray.removeAll()
        self.snackArray.removeAll()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let frontNum = yearsTextField.text else {return}
        guard let backNum = monthsTextField.text else {return}
        guard let documentID = daysTextField.text else {return}
        let collectionID = frontNum + backNum
        
        Firestore.firestore().collection("users").document(uid).collection(collectionID).document(documentID).collection("breakfast").getDocuments { SnapshotMetadata, Error in
            if Error != nil {
                print("データの取得に失敗しました。",Error.debugDescription)
                return
            }
            
            if let snapShotDoc = SnapshotMetadata?.documents {
                var brC:Double = 0
                var brP:Double = 0
                var brF:Double = 0
                var brK:Double = 0
                for doc in snapShotDoc {
                    let data = doc.data()
                    if let foodName = data["foodName"] as? String,let carb = data["carb"] as? String,let protein = data["protein"] as? String,let fat = data["fat"] as? String,let kcal = data["kcal"] as? String{
                        let foodModel = FoodsModel(foodName: foodName, carb: carb, protein: protein, fat: fat,kcal: kcal)
                        self.breakfastArray.append(foodModel)
                        brC += Double(carb)!
                        brP += Double(protein)!
                        brF += Double(fat)!
                        brK += Double(kcal)!
                        
                    }
                    
                }
                self.breakfastCarbLabel.text = String(brC)
                self.breakFastProteinLabel.text = String(brP)
                self.breakfastFatLabel.text = String(brF)
                self.breakfastKcalLabel.text = String(brK)
                self.breakfastTableView.reloadData()
                
                
                Firestore.firestore().collection("users").document(uid).collection(String(collectionID)).document(String(documentID)).collection("lunch").getDocuments { SnapshotMetadata, Error in
                    if Error != nil {
                        print("データの取得に失敗しました。",Error.debugDescription)
                        return
                    }
                    
                    if let snapShotDoc = SnapshotMetadata?.documents {
                        var luC:Double = 0
                        var luP:Double = 0
                        var luF:Double = 0
                        var luK:Double = 0
                        for doc in snapShotDoc {
                            let data = doc.data()
                            if let foodName = data["foodName"] as? String,let carb = data["carb"] as? String,let protein = data["protein"] as? String,let fat = data["fat"] as? String,let kcal = data["kcal"] as? String{
                                let foodModel = FoodsModel(foodName: foodName, carb: carb, protein: protein, fat: fat,kcal: kcal)
                                self.lunchArray.append(foodModel)
                                luC += Double(carb)!
                                luP += Double(protein)!
                                luF += Double(fat)!
                                luK += Double(kcal)!
                            }
                        }
                        self.lunchCarbLabel.text = String(luC)
                        self.lunchProteinLabel.text = String(luP)
                        self.lunchFatLabel.text = String(luF)
                        self.lunchKcalLabel.text = String(luK)
                        self.lunchTableView.reloadData()
                        
                        Firestore.firestore().collection("users").document(uid).collection(String(collectionID)).document(String(documentID)).collection("dinner").getDocuments { SnapshotMetadata, Error in
                            if Error != nil {
                                print("データの取得に失敗しました。",Error.debugDescription)
                                return
                            }
                            
                            if let snapShotDoc = SnapshotMetadata?.documents {
                                var diC:Double = 0
                                var diP:Double = 0
                                var diF:Double = 0
                                var diK:Double = 0
                                for doc in snapShotDoc {
                                    let data = doc.data()
                                    if let foodName = data["foodName"] as? String,let carb = data["carb"] as? String,let protein = data["protein"] as? String,let fat = data["fat"] as? String,let kcal = data["kcal"] as? String{
                                        let foodModel = FoodsModel(foodName: foodName, carb: carb, protein: protein, fat: fat,kcal: kcal)
                                        self.dinnerArray.append(foodModel)
                                        diC += Double(carb)!
                                        diP += Double(protein)!
                                        diF += Double(fat)!
                                        diK += Double(kcal)!
                                    }
                                }
                                self.dinnerCarbLabel.text = String(diC)
                                self.dinnerProteinLabel.text = String(diP)
                                self.dinnerFatLabel.text = String(diF)
                                self.dinnerKcalLabel.text = String(diK)
                                self.dinnerTableView.reloadData()
                                
                                Firestore.firestore().collection("users").document(uid).collection(String(collectionID)).document(String(documentID)).collection("snack").getDocuments { SnapshotMetadata, Error in
                                    if Error != nil {
                                        print("データの取得に失敗しました。",Error.debugDescription)
                                        return
                                    }
                                    
                                    if let snapShotDoc = SnapshotMetadata?.documents {
                                        var snC:Double = 0
                                        var snP:Double = 0
                                        var snF:Double = 0
                                        var snK:Double = 0
                                        for doc in snapShotDoc {
                                            let data = doc.data()
                                            if let foodName = data["foodName"] as? String,let carb = data["carb"] as? String,let protein = data["protein"] as? String,let fat = data["fat"] as? String,let kcal = data["kcal"] as? String{
                                                let foodModel = FoodsModel(foodName: foodName, carb: carb, protein: protein, fat: fat,kcal: kcal)
                                                self.snackArray.append(foodModel)
                                                snC += Double(carb)!
                                                snP += Double(protein)!
                                                snF += Double(fat)!
                                                snK += Double(kcal)!
                                            }
                                        }
                                        self.snackCarbLabel.text = String(snC)
                                        self.snackProteinLabel.text = String(snP)
                                        self.snackFatLabel.text = String(snF)
                                        self.snackKcalLabel.text = String(snK)
                                        self.snackTableView.reloadData()
                                        
                                        self.calcPFC()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func changeIsEnabled(){
        if monthsTextField.text == "04" && daysTextField.text == "31"{
            changeDateButton.isEnabled = false
            changeDateButton.backgroundColor = UIColor.rgb(red: 221, green: 221, blue: 221)
            
        }else if monthsTextField.text == "06" && daysTextField.text == "31"{
            changeDateButton.isEnabled = false
            changeDateButton.backgroundColor = UIColor.rgb(red: 221, green: 221, blue: 221)
            
        }else if monthsTextField.text == "09" && daysTextField.text == "31"{
            changeDateButton.isEnabled = false
            changeDateButton.backgroundColor = UIColor.rgb(red: 221, green: 221, blue: 221)
            
        }else if monthsTextField.text == "11" && daysTextField.text == "31"{
            changeDateButton.isEnabled = false
            changeDateButton.backgroundColor = UIColor.rgb(red: 221, green: 221, blue: 221)
            
        }else if monthsTextField.text == "02" && daysTextField.text == "30"{
            changeDateButton.isEnabled = false
            changeDateButton.backgroundColor = UIColor.rgb(red: 221, green: 221, blue: 221)
            
        }else if monthsTextField.text == "02" && daysTextField.text == "31"{
            changeDateButton.isEnabled = false
            changeDateButton.backgroundColor = UIColor.rgb(red: 221, green: 221, blue: 221)
            
        }else{
            changeDateButton.isEnabled = true
            changeDateButton.backgroundColor = UIColor.rgb(red: 48, green: 209, blue: 88)
            
        }
    }
//    func nextButtonIsEnabled(){
//        guard let yearsNum = yearsTextField.text else {return}
//        guard let monthsNum = monthsTextField.text else {return}
//        guard let daysNum = daysTextField.text else {return}
//        let dateNum = yearsNum + monthsNum + daysNum
//        let date = GetDateModel.getTodayDate()
//        if date != dateNum {
//            nextButton.isEnabled = false
//            nextButton.backgroundColor = UIColor.rgb(red: 221, green: 221, blue: 221)
//        }else{
//            nextButton.isEnabled = true
//            nextButton.backgroundColor = UIColor.rgb(red: 48, green: 209, blue: 88)
//        }
//    }
    
    private func calcPFC(){
        
        let totalC = Double(breakfastCarbLabel.text!)! + Double(lunchCarbLabel.text!)! + Double(dinnerCarbLabel.text!)! + Double(snackCarbLabel.text!)!
        totalCarbLabel.text = "\(String(totalC))g"
        let totalP = Double(breakFastProteinLabel.text!)! + Double(lunchProteinLabel.text!)! + Double(dinnerProteinLabel.text!)! + Double(snackProteinLabel.text!)!
        totalProteinLabel.text = "\(String(totalP))g"
        let totalF = Double(breakfastFatLabel.text!)! + Double(lunchFatLabel.text!)! + Double(dinnerFatLabel.text!)! + Double(snackFatLabel.text!)!
        totalFatLabel.text = "\(String(totalF))g"
        let totalK = Double(breakfastKcalLabel.text!)! + Double(lunchKcalLabel.text!)! + Double(dinnerKcalLabel.text!)! + Double(snackKcalLabel.text!)!
        totalKcalLabel.text = "\(String(totalK))kcal"
    }
    
    @IBAction func changeDateButton(_ sender: Any) {
        loadMealsFromFirestore()
//        nextButtonIsEnabled()
    }
    
    func makeDateID(){
        guard let yearNum = yearsTextField.text else {return}
        guard let monthNum = monthsTextField.text else {return}
        guard let dayNum = daysTextField.text else {return}
        UserDefaults.standard.setValue(yearNum, forKey: "yearNum")
        UserDefaults.standard.setValue(monthNum, forKey: "monthNum")
        UserDefaults.standard.setValue(dayNum, forKey: "dayNum")
    }
    
    @IBAction func nextButton(_ sender: Any) {
        makeDateID()
        performSegue(withIdentifier: "registration", sender: nil)
    }
    
    @IBAction func showImageButton(_ sender: Any) {
        imagesUIView.isHidden = false
        if let button = sender as? UIButton {
            if button.tag == 1 {
                time = "breakfast"
                loadImageFromFirestore()
                imagesUIView.isHidden = false
            }else if button.tag == 2 {
                time = "lunch"
                loadImageFromFirestore()
                imagesUIView.isHidden = false
            }else if button.tag == 3 {
                time = "dinner"
                loadImageFromFirestore()
                imagesUIView.isHidden = false
            }else if button.tag == 4 {
                time = "snack"
                loadImageFromFirestore()
                imagesUIView.isHidden = false
            }
        }
    }
    private func loadImageFromFirestore(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let yearsNum = yearsTextField.text else {return}
        guard let monthsNum = monthsTextField.text else {return}
        guard let daysNum = daysTextField.text else {return}
        let date = yearsNum + monthsNum + daysNum
        let imageRef = Storage.storage().reference().child("mealImage").child(uid).child(date).child("\(uid + time + date)")
        imageRef.downloadURL { URL, Error in
            if Error != nil{
                print("urlの取得に失敗しました。",Error.debugDescription)
                return
            }
            if let imageString = URL?.absoluteURL {
                self.mealsImageView.sd_setImage(with: imageString, completed: nil)
            }
        }
    }

}

extension ViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if tableView.tag == 1 {
            count = breakfastArray.count
        }else if tableView.tag == 2 {
            count = lunchArray.count
        }else if tableView.tag == 3 {
            count = dinnerArray.count
        }else if tableView.tag == 4 {
            count = snackArray.count
        }
        return count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = MealsTableViewCell()
        if tableView.tag == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "breakfastCell", for: indexPath) as! MealsTableViewCell
            cell.foodNameLabel.text = breakfastArray[indexPath.row].foodName
            cell.carbLabel.text = "\(breakfastArray[indexPath.row].carb)g"
            cell.proteinLabel.text = "\(breakfastArray[indexPath.row].protein)g"
            cell.fatLabel.text = "\(breakfastArray[indexPath.row].fat)g"
            cell.kcalLabel.text = breakfastArray[indexPath.row].kcal
        }else if tableView.tag == 2 {
            cell = tableView.dequeueReusableCell(withIdentifier: "lunchCell", for: indexPath) as! MealsTableViewCell
            cell.foodNameLabel.text = lunchArray[indexPath.row].foodName
            cell.carbLabel.text = "\(lunchArray[indexPath.row].carb)g"
            cell.proteinLabel.text = "\(lunchArray[indexPath.row].protein)g"
            cell.fatLabel.text = "\(lunchArray[indexPath.row].fat)g"
            cell.kcalLabel.text = lunchArray[indexPath.row].kcal
        }else if tableView.tag == 3 {
            cell = tableView.dequeueReusableCell(withIdentifier: "dinnerCell", for: indexPath) as! MealsTableViewCell
            cell.foodNameLabel.text = dinnerArray[indexPath.row].foodName
            cell.carbLabel.text = "\(dinnerArray[indexPath.row].carb)g"
            cell.proteinLabel.text = "\(dinnerArray[indexPath.row].protein)g"
            cell.fatLabel.text = "\(dinnerArray[indexPath.row].fat)g"
            cell.kcalLabel.text = dinnerArray[indexPath.row].kcal
        }else if tableView.tag == 4 {
            cell = tableView.dequeueReusableCell(withIdentifier: "snackCell", for: indexPath) as! MealsTableViewCell
            cell.foodNameLabel.text = snackArray[indexPath.row].foodName
            cell.carbLabel.text = "\(snackArray[indexPath.row].carb)g"
            cell.proteinLabel.text = "\(snackArray[indexPath.row].protein)g"
            cell.fatLabel.text = "\(snackArray[indexPath.row].fat)g"
            cell.kcalLabel.text = snackArray[indexPath.row].kcal
        }
        
        return cell
    }
}

extension ViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var pickerViewTitle = String()
        if pickerView.tag == 1 {
            pickerViewTitle = years[row]
            
        } else if pickerView.tag == 2 {
            pickerViewTitle =  months[row]
            
        } else if pickerView.tag == 3 {
            pickerViewTitle = days1[row]
            
        }
        return pickerViewTitle
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            yearsTextField.text = years[row]
            yearsTextField.resignFirstResponder()
        } else if pickerView.tag == 2 {
            monthsTextField.text = months[row]
            monthsTextField.resignFirstResponder()
            
        } else if pickerView.tag == 3 {
            daysTextField.text = days1[row]
            daysTextField.resignFirstResponder()
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count = Int()
        if pickerView.tag == 1 {
            count = years.count
        } else if pickerView.tag == 2 {
            count = months.count
        } else if pickerView.tag == 3 {
            count = days1.count
        }
        return count
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        changeIsEnabled()
        
    }
}
extension ViewController: AlertDelegate {
    func tappedRegisterButton() {
        alertSystem.showAlert(title: "お食事の登録が完了しました。", message: "ご報告ありがとうございます！", buttonTitle: "OK!", viewController: self)
    }
    
    
}


