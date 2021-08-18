//
//  LoginViewController.swift
//  MealManagementApp
//
//  Created by 酒井直輝 on 2021/07/12.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import PKHUD
class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        loginButton.layer.cornerRadius = 10
        loginButton.layer.cornerRadius = 10
        loginButton.isEnabled = false
        loginButton.backgroundColor = UIColor.rgb(red: 221, green: 255, blue: 221)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    //keyboardが出てきたらkeyboardの差分だけView全体を上にずらす
    
    @objc func showKeyboard(notification: Notification){
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        guard let keyboardMinY = keyboardFrame?.minY else {return}
        let loginButtonMaxY = loginButton.frame.maxY
        let distance = loginButtonMaxY - keyboardMinY + 20
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
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    @IBAction func loginButton(_ sender: Any) {
        HUD.show(.progress, onView: self.view)
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        Auth.auth().signIn(withEmail: email, password: password) { Result, Error in
            if Error != nil{
                print("ログインに失敗しました。",Error.debugDescription)
                return
            }
            print("ログインに成功しました。")
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let userRef = Firestore.firestore().collection("users").document(uid)
            userRef.getDocument { SnapshotMetadata, Error in
                if Error != nil{
                    print("ユーザー情報の取得に失敗しました。\(Error.debugDescription)")
                    HUD.hide { (_) in
                        HUD.flash(.error, delay: 1)
                    }
                    return
                }
                guard let data = SnapshotMetadata?.data() else {return}
                let user = User.init(dic: data)
                print("ユーザー情報の取得に成功しました\(user.userName)")
                HUD.hide { (_) in
                    HUD.flash(.success, onView: self.view, delay: 1) { (_) in
                        self.performSegue(withIdentifier: "tab", sender: nil)
                        
                    }
                }
            }
        }
    }
    private func presentToViewController(user: User){
        //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard?.instantiateViewController(identifier: "viewController") as! ViewController
        viewController.user = user
        viewController.modalPresentationStyle = .fullScreen
        //        self.present(viewController, animated: true, completion: nil)
        performSegue(withIdentifier: "tab", sender: nil)
        
    }
    
    
    
}

extension LoginViewController: UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? true
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
        
        
        if emailIsEmpty || passwordIsEmpty {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.rgb(red: 221, green: 255, blue: 221)
        }else{
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor.rgb(red: 0, green: 255, blue: 0)
        }
    }
}
