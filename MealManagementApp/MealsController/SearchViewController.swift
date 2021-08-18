//
//  SearchViewController.swift
//  MealManagementApp
//
//  Created by 酒井直輝 on 2021/07/12.
//

import UIKit
import Firebase
import FirebaseFirestore

protocol SearchToRegistrationDelegate {
    func searchToRegistration(food:FoodsModel)
}

class SearchViewController: UIViewController,SettingToSearchDelegate {
 
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var foodsArray:[FoodsModel] = []
    var searchResultArray:[FoodsModel] = []
   
    var foodName = String()
    var carb = String()
    var protein = String()
    var fat = String()
    var kcal = String()
    var delegate:SearchToRegistrationDelegate?
    var alertSystem = AlertSystem()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchResultArray = foodsArray
        loadFireStore()
        tableView.backgroundColor = .white
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setting"{
            let settingVC = segue.destination as! SettingViewController
            settingVC.delegate = self
            settingVC.foodName = foodName
            settingVC.carb = carb
            settingVC.protein = protein
            settingVC.fat = fat
            settingVC.kcal = kcal
        }else if segue.identifier == "manual"{
            let manualVC = segue.destination as! ManualInputViewController
            manualVC.delegate = self
        }
    }
    
    func settingToSearch(food: FoodsModel) {
        let food = food
        delegate?.searchToRegistration(food: food)
    }
    
    func loadFireStore(){
        let db = Firestore.firestore()
       
        db.collection("foods").addSnapshotListener { SnapshotMetadata, Error in
            if Error != nil{
                print("error")
                return
            }
            if let snapShotDoc = SnapshotMetadata?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    if let foodName = data["foodName"] as? String,let carb = data["carb"] as? String,let protein = data["protein"] as? String,let fat = data["fat"] as? String,let kcal = data["kcal"] as? String{
                        let foodModel = FoodsModel(foodName: foodName, carb: carb, protein: protein, fat: fat,kcal: kcal)
                        self.foodsArray.append(foodModel)
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func tappedManualInputButton(_ sender: Any) {
        performSegue(withIdentifier: "manual", sender: nil)
    }
}



extension SearchViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResultArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        foodName = searchResultArray[indexPath.row].foodName
        carb = searchResultArray[indexPath.row].carb
        protein = searchResultArray[indexPath.row].protein
        fat = searchResultArray[indexPath.row].fat
        kcal = searchResultArray[indexPath.row].kcal
        
        performSegue(withIdentifier: "setting", sender: nil)
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = searchResultArray[indexPath.row].foodName
        cell.backgroundColor = .white
        cell.textLabel?.textColor = .black
        return cell
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
        //検索結果配列を空にする。
       
        
        if(searchBar.text == "") {
            //検索文字列が空の場合はすべてを表示する。
            searchResultArray = foodsArray
        } else {
//          foodsArrayからsearchBarのテキストに回答する項目を抜選する。
            searchResultArray = foodsArray.filter({ (str) in

                return str.foodName.contains(searchBar.text!)

            })
            
        }
     tableView.reloadData()
    }
}

extension SearchViewController: AlertToSearchDelegate{
    func tappedInputButton() {
        alertSystem.showAlert(title: "入力完了！", message: "ご協力ありがとうございます！\n入力内容が他の方にも使えるようになりました！", buttonTitle: "OK!", viewController: self)
    }
    
    
}

