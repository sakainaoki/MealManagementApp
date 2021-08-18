//
//  RegistrationViewController.swift
//  MealManagementApp
//
//  Created by 酒井直輝 on 2021/07/12.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
protocol AlertDelegate {
    func tappedRegisterButton()
}

class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var mealImageView: UIImageView!
    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var carbLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var foodTableView: UITableView!
    @IBOutlet weak var registrationButton: UIButton!
   
    
    var pickerView = UIPickerView()
    var delegate:AlertDelegate?
    let times = ["朝食","昼食","夕食","間食"]
    var time = String()
    var foods:[FoodsModel] = []
    var carb = Double()
    var protein = Double()
    var fat = Double()
    var kcal = Double()
    
    var foodName = String()
    var carbString = String()
    var proteinString = String()
    var fatString = String()
    var kcalString = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        timeTextField.delegate = self
       
        foodTableView.delegate = self
        foodTableView.dataSource = self
        pickerView.dataSource = self
        pickerView.delegate = self
        carbLabel.text = String(carb)
        proteinLabel.text = String(protein)
        fatLabel.text = String(fat)
        kcalLabel.text = String(kcal)
        foodTableView.backgroundColor = .white
        timeTextField.backgroundColor = .white
        timeTextField.textColor = .black
        timeTextField.inputView = pickerView
        timeTextField.layer.cornerRadius = 17
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        changeIsEnabled()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let searchVC = segue.destination as! SearchViewController
        searchVC.delegate = self
    }
    
    func changeIsEnabled(){
        if timeTextField.text == "入力してください" {
            registrationButton.isEnabled = false
            registrationButton.backgroundColor = UIColor.rgb(red: 169, green: 169, blue: 169)
        }else if timeTextField.text != "入力してください" && mealImageView.image == nil && foods.isEmpty == true {
            registrationButton.isEnabled = false
            registrationButton.backgroundColor = UIColor.rgb(red: 169, green: 169, blue: 169)
        }else if timeTextField.text != "入力してください" && mealImageView.image != nil && foods.isEmpty == true{
            registrationButton.isEnabled = true
            registrationButton.backgroundColor = UIColor.rgb(red: 48, green: 209, blue: 88)
        }else if timeTextField.text != "入力してください" && mealImageView.image == nil && foods.isEmpty == false {
            registrationButton.isEnabled = true
            registrationButton.backgroundColor = UIColor.rgb(red: 48, green: 209, blue: 88)
        }else if timeTextField.text != "入力してください" && mealImageView.image != nil && foods.isEmpty == false {
            registrationButton.isEnabled = true
            registrationButton.backgroundColor = UIColor.rgb(red: 48, green: 209, blue: 88)
        }else{
            registrationButton.isEnabled = false
            registrationButton.backgroundColor = UIColor.rgb(red: 169, green: 169, blue: 169)
        }
    }
    
    @IBAction func addMenuButton(_ sender: Any) {
        performSegue(withIdentifier: "search", sender: nil)

    }
    
    private func sendToFireStore(){
        if foods.isEmpty != true {
            print("sendToFireStore()")
            if timeTextField.text == "朝食" {
                time = "breakfast"
            }else if timeTextField.text == "昼食" {
                time = "lunch"
            }else if timeTextField.text == "夕食" {
                time = "dinner"
            }else if timeTextField.text == "間食" {
                time = "snack"
            }
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let date = GetDateModel.getTodayDate()
            let collectionID = date.prefix(6)
            let documentID = date.suffix(2)
            for data in foods {
                let docData = ["foodName":data.foodName,
                               "carb":data.carb,
                               "protein":data.protein,
                               "fat":data.fat,
                               "kcal":data.kcal]
                Firestore.firestore().collection("users").document(uid).collection(String(collectionID)).document(String(documentID)).collection(time).document().setData(docData) { Error in
                    if Error != nil {
                        print("fireStoreへの保存に失敗しました。")
                        return
                    }
                    print("fireStoreへの保存に成功しました。")
                }
            }
        }
    }
    
    
    private func sendToFirebaseStorage(){
        if mealImageView.image != nil {
            print("sendToFirebaseStorage()")
            if timeTextField.text == "朝食" {
                time = "breakfast"
            }else if timeTextField.text == "昼食" {
                time = "lunch"
            }else if timeTextField.text == "夕食" {
                time = "dinner"
            }else if timeTextField.text == "間食" {
                time = "snack"
            }
            guard let image = self.mealImageView.image else {return}
            
            let data = image.jpegData(compressionQuality: 1.0)
            SendToStrageModel.sendMealImageData(data: data!, time: time)
        }
        
    }
    
    @IBAction func registrationButton(_ sender: Any) {
        sendToFireStore()
        sendToFirebaseStorage()
        self.navigationController?.popViewController(animated: true)
        delegate?.tappedRegisterButton()
    }
    
    
    @IBAction func tappedMealsImageView(_ sender: Any) {
        let checkPermission = CheckPermission()
        checkPermission.showCheckPermission()
        showAlert()
    }
    
    
    //カメラ立ち上げメソッド
        
        func doCamera(){
            
            let sourceType:UIImagePickerController.SourceType = .camera
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let cameraPicker = UIImagePickerController()
                cameraPicker.allowsEditing = true
                cameraPicker.sourceType = sourceType
                cameraPicker.delegate = self
                self.present(cameraPicker, animated: true, completion: nil)
                changeIsEnabled()
            }
            
        }
    
        func doAlbum(){
            let sourceType:UIImagePickerController.SourceType = .photoLibrary
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                
                let cameraPicker = UIImagePickerController()
                cameraPicker.allowsEditing = true
                cameraPicker.sourceType = sourceType
                cameraPicker.delegate = self
                self.present(cameraPicker, animated: true, completion: nil)
                changeIsEnabled()
            }
            
        }
        
        //アラート
        func showAlert(){
            
            let alertController = UIAlertController(title: "選択", message: "どちらを使用しますか?", preferredStyle: .actionSheet)
            let action1 = UIAlertAction(title: "カメラ", style: .default) { (alert) in
                self.doCamera()
            }
            let action2 = UIAlertAction(title: "アルバム", style: .default) { (alert) in
                self.doAlbum()
            }
            let action3 = UIAlertAction(title: "写真を削除", style: .default) { (alert) in
                self.mealImageView.image = nil
                self.changeIsEnabled()
            }
            let action4 = UIAlertAction(title: "キャンセル", style: .cancel)
            
            alertController.addAction(action1)
            alertController.addAction(action2)
            alertController.addAction(action3)
            alertController.addAction(action4)
            self.present(alertController, animated: true, completion: nil)
            
        }
    
}

extension RegistrationViewController: UITextFieldDelegate{
   
    func textFieldDidChangeSelection(_ textField: UITextField) {
        changeIsEnabled()
    }
}

extension RegistrationViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        foodName = foods[indexPath.row].foodName
        carbString = foods[indexPath.row].carb
        proteinString = foods[indexPath.row].protein
        fatString = foods[indexPath.row].fat
        kcalString = foods[indexPath.row].kcal
        
        performSegue(withIdentifier: "regiEdit", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.foods.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let foodsCell = tableView.dequeueReusableCell(withIdentifier: "foodsCell", for: indexPath)
        foodsCell.textLabel?.text = foods[indexPath.row].foodName
        foodsCell.backgroundColor = .white
        foodsCell.textLabel?.textColor = .black
        return foodsCell
    }
}


extension RegistrationViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return times.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        timeTextField.text = times[row]
        timeTextField.resignFirstResponder()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return times[row]
    }
}

extension RegistrationViewController: SearchToRegistrationDelegate {
    func searchToRegistration(food: FoodsModel) {
        carb += Double(food.carb)!
        protein += Double(food.protein)!
        fat += Double(food.fat)!
        kcal += Double(food.kcal)!
        carbLabel.text = String(carb)
        proteinLabel.text = String(protein)
        fatLabel.text = String(fat)
        kcalLabel.text = String(kcal)
        foods.append(food)
        foodTableView.reloadData()
    }
}

extension RegistrationViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            
            if info[.originalImage] as? UIImage != nil{
                
                let selectedImage = info[.originalImage] as! UIImage
                mealImageView.image = selectedImage
                picker.dismiss(animated: true, completion: nil)
                
            }
            
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            
            picker.dismiss(animated: true, completion: nil)
            
        }
    
}

extension RegistrationViewController: UINavigationControllerDelegate {
    
}



