//
//  ChartViewController.swift
//  MealManagementApp
//
//  Created by 酒井直輝 on 2021/08/06.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import EMAlertController
import Charts
class ChartViewController: UIViewController {
    @IBOutlet weak var targetWeightLabel: UILabel!
    @IBOutlet weak var nowWeightLabel: UILabel!
    @IBOutlet weak var differenceLabel: UILabel!
    @IBOutlet weak var yearsTextField: UITextField!
    @IBOutlet weak var monthsTextField: UITextField!
    @IBOutlet weak var changeMonthsButton: UIButton!
    @IBOutlet weak var todaysWeightTextField: UITextField!
    @IBOutlet weak var weightUpdateButton: UIButton!
    @IBOutlet weak var chartView: LineChartView!
    
    let alertSystem = AlertSystem()
    var yearsPickerView = UIPickerView()
    var monthsPickerView = UIPickerView()
    var loadModel = LoadModel()
    let years = ["2021","2022","2023","2024","2025","2026","2027","2028","2029","2030","2031"]
    let months = ["01","02","03","04","05","06","07","08","09","10","11","12"]
    var chartArray:[PersonalData] = []
    let date = GetDateModel.getTodayDate()
    override func viewDidLoad() {
        super.viewDidLoad()
        todaysWeightTextField.delegate = self
        yearsPickerView.delegate = self
        yearsPickerView.dataSource = self
        monthsPickerView.delegate = self
        monthsPickerView.dataSource = self
        loadModel.getDataProtocol = self
        yearsTextField.inputView = yearsPickerView
        monthsTextField.inputView = monthsPickerView
        yearsPickerView.tag = 1
        monthsPickerView.tag = 2
        weightUpdateButtonIsEnabled()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        loadModel.loadTargetWeight(userUid: uid)
        calcWeight()
        changeMonthsButton.layer.cornerRadius = 10
        weightUpdateButton.layer.cornerRadius = 25
        yearsTextField.text = String(date.prefix(4))
        let startIndex = date.index(date.startIndex, offsetBy: 4)
        let endIndex = date.index(date.startIndex, offsetBy: 6)
        let month = date[startIndex..<endIndex]
        monthsTextField.text = String(month)
//        loadWeightFromFirestore()
        if UserDefaults.standard.object(forKey: "nowWeight") != nil{
            nowWeightLabel.text = "\(UserDefaults.standard.object(forKey: "nowWeight") as! String)kg"
            
        }else{
            nowWeightLabel.text = "---kg"
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let year = String(date.prefix(4))
        let startIndex = date.index(date.startIndex, offsetBy: 4)
        let endIndex = date.index(date.startIndex, offsetBy: 6)
        let month = String(date[startIndex..<endIndex])
        loadModel.loadMyRecordData(userID: uid, year: year, month: month)
        
    }
    
    @objc func showKeyboard(notification: Notification){
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        guard let keyboardMinY = keyboardFrame?.minY else {return}
        let weightUpdateButtonMaxY = weightUpdateButton.frame.maxY
        let distance = weightUpdateButtonMaxY - keyboardMinY + 20
        let transform = CGAffineTransform(translationX: 0, y: -distance)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.view.transform = transform
        })
        
    }
    
    @objc func hideKeyboard(){
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.view.transform = .identity
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func sendWeightToFirestore(){
        guard let todaysWeight = todaysWeightTextField.text else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let year = String(date.prefix(4))
        let startIndex = date.index(date.startIndex, offsetBy: 4)
        let endIndex = date.index(date.startIndex, offsetBy: 6)
        let month = String(date[startIndex..<endIndex])
        let day = String(date.suffix(2))
        let docData = ["bodyWeight":todaysWeight,"date":date]
        Firestore.firestore().collection("users").document(uid).collection("bodyWeights").document(year).collection(month).document(day).setData(docData) { Error in
            if Error != nil {
                print("体重の保存に失敗しました。",Error.debugDescription)
                return
            }
            self.view.endEditing(true)
            UserDefaults.standard.setValue(todaysWeight, forKey: "nowWeight")
            self.nowWeightLabel.text = "\(UserDefaults.standard.object(forKey: "nowWeight") as! String)kg"
            self.todaysWeightTextField.text = ""
            self.weightUpdateButton.isEnabled = false
            self.weightUpdateButton.backgroundColor = UIColor.rgb(red: 169, green: 169, blue: 169)
            self.alertSystem.showAlert(title: "体重入力完了！", message: "ご報告ありがとうございます！", buttonTitle: "OK", viewController: self)
            self.loadModel.loadMyRecordData(userID: uid, year: year, month: month)
        }
    }
    
    func calcWeight() {
        guard let targetWeight = UserDefaults.standard.object(forKey: "targetWeight") else {return}
        guard let nowWeight = UserDefaults.standard.object(forKey: "nowWeight") else {return}
        let difference = Float(targetWeight as! Substring)! - Float(nowWeight as! Substring)!
        let difference2 = difference * 10
        targetWeightLabel.text = "\(targetWeight)kg"
        nowWeightLabel.text = "\(nowWeight)kg"
        differenceLabel.text = "\(floor(difference2) / 10)kg"
    }
    
    private func changeMonth(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let year = yearsTextField.text else {return}
        guard let month = monthsTextField.text else {return}
        loadModel.loadMyRecordData(userID: uid, year: year, month: month)
    }
    @IBAction func tappedChangeMonthButton(_ sender: Any) {
        changeMonth()
    }
    
    @IBAction func tappedWeightUpdateButton(_ sender: Any) {
        sendWeightToFirestore()

    }
    
}
extension ChartViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        weightUpdateButtonIsEnabled()
    }
    func weightUpdateButtonIsEnabled(){
        if todaysWeightTextField.text?.isEmpty == true {
            weightUpdateButton.isEnabled = false
            weightUpdateButton.backgroundColor = UIColor.rgb(red: 169, green: 169, blue: 169)
        }else{
            weightUpdateButton.isEnabled = true
            weightUpdateButton.backgroundColor = UIColor.rgb(red: 48, green: 209, blue: 88)
        }
        
    }
}
extension ChartViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var pickerViewTitle = String()
        if pickerView.tag == 1 {
            pickerViewTitle = years[row]
            
        } else if pickerView.tag == 2 {
            pickerViewTitle =  months[row]
            
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
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count = Int()
        if pickerView.tag == 1 {
            count = years.count
        } else if pickerView.tag == 2 {
            count = months.count
        }
        return count
    }
}


extension ChartViewController: GetDataProtocol{
    func getData(dataArray: [PersonalData]) {
        chartArray = dataArray
        setUpChart(values: chartArray)
        
    }
   
}
extension ChartViewController:ChartViewDelegate {
    func setUpChart(values:[PersonalData]){
        
        var entry = [ChartDataEntry]()
        for i in 0..<values.count{
            entry.append(ChartDataEntry(x: Double(i), y: Double(values[i].weight)!))
        }
        let dataSet = LineChartDataSet(entries: entry, label: "体重")
        chartView.data = LineChartData(dataSet: dataSet)
    }
    func setUpLineChart(_ chart:LineChartView,data:LineChartData){
        chart.delegate = self
        chart.chartDescription?.enabled = true
        chart.dragEnabled = true
        chart.setScaleEnabled(true)
        chart.setViewPortOffsets(left: 30, top: 0, right: 0, bottom: 30)
        chart.legend.enabled = true
        chart.leftAxis.enabled = true
        chart.leftAxis.spaceTop = 0.4
        chart.leftAxis.spaceBottom = 0.4
        
        chart.rightAxis.enabled = false
        chart.xAxis.enabled = true
        chart.data = data
        chart.animate(xAxisDuration: 2)
    }
    
}

