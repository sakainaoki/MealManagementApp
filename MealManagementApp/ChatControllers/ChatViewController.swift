//
//  ChatViewController.swift
//  MealManagementApp
//
//  Created by 酒井直輝 on 2021/07/28.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
class ChatViewController: UIViewController {
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    var messages = [MessagesModel]()
   var loadModel = LoadModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableView.delegate = self
        chatTableView.dataSource = self
        messageTextView.delegate = self
        chatTableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: "chatCell")
        sendButton.layer.cornerRadius = 25
        messageTextView.backgroundColor = .white
        messageTextView.layer.cornerRadius = 10
        sendButtonIsEnabled()
        loadMessageFromFirestore()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Do any additional setup after loading the view.
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    private func sendButtonIsEnabled(){
        if messageTextView.text.isEmpty == true{
            sendButton.isEnabled = false
            sendButton.backgroundColor = UIColor.rgb(red: 169, green: 169, blue: 169)
        }else{
            sendButton.isEnabled = true
            sendButton.backgroundColor = UIColor.rgb(red: 64, green: 200, blue: 224)
        }
    }
    @objc func showKeyboard(notification: Notification){
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        guard let keyboardMinY = keyboardFrame?.minY else {return}
        let sendButtonMaxY = sendButton.frame.maxY
        let distance = sendButtonMaxY - keyboardMinY + 20
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
    
    private func loadMessageFromFirestore(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).collection("messages").order(by: "timeStamp").addSnapshotListener { SnapshotMetadata, Error in
            self.messages = []
            if Error != nil{
                print("messageの取得に失敗しました。")
                return
            }
            if let snapShotDoc = SnapshotMetadata?.documents {
                for doc in snapShotDoc {
                    let data = doc.data()
                    if let sender = data["uid"] as? String,let message = data["message"] as? String,let date = data["date"] as? String,let time = data["time"] as? String,let read = data["read"] as? Bool,let dayAndTime = data["dayAndTime"] as? String{
                        let message = MessagesModel(uid: sender, message: message, date: date, time: time, read: read, dayAndTime: dayAndTime)
                        self.messages.append(message)
                        
                        DispatchQueue.main.async {
                            self.chatTableView.reloadData()
                            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                            self.chatTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            
                        }
                    }
                }
            }
        }
    }
    
    
    private func sendMessageToFirestore(){
        messages.removeAll()
        let date = GetDateModel.getTodayDate()
        let time = GetDateModel.getTimeDate()
        let dayAndTime = GetDateModel.getTodayAndTimeDate()
        let read = false
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let message = messageTextView.text else {return}
        let messageDocData = ["uid":uid,
                              "message": message,
                              "date":date,
                              "time":time,
                              "read":read,
                              "dayAndTime":dayAndTime,
                              "timeStamp":Timestamp()] as [String : Any]
        Firestore.firestore().collection("users").document(uid).collection("messages").document(String(dayAndTime)).setData(messageDocData) { Error in
            if Error != nil{
                print("messageの保存に失敗しました。",Error.debugDescription)
                return
            }
            DispatchQueue.main.async {
                self.messageTextView.text = ""
                self.messageTextView.resignFirstResponder()
            }
        }
    }
    @IBAction func tappedSendButton(_ sender: Any) {
        sendMessageToFirestore()
    }
}

extension ChatViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatTableViewCell
        if messages[indexPath.row].uid == Auth.auth().currentUser?.uid {
            cell.myMessageTextView.isHidden = false
            cell.myTimeLabel.isHidden = false
            cell.partnerImageView.isHidden = true
            cell.partnersMessageTextView.isHidden = true
            cell.partnerTimeLabel.isHidden = true
            
            let width = estimateFrameForTextView(text: messages[indexPath.row].message).width + 20
            cell.myMessageTextViewWidth.constant = width
            cell.myMessageTextView.layer.cornerRadius = 10
            cell.myMessageTextView.text = messages[indexPath.row].message
            cell.myTimeLabel.text = "\(messages[indexPath.row].time.prefix(2)):\(messages[indexPath.row].time.suffix(2))"
            
        }else{
            cell.partnerImageView.isHidden = false
            cell.partnersMessageTextView.isHidden = false
            cell.partnerTimeLabel.isHidden = false
            cell.myMessageTextView.isHidden = true
            cell.myTimeLabel.isHidden = true
            let width = estimateFrameForTextView(text: messages[indexPath.row].message).width + 20
            cell.partnersMessageTextViewWidth.constant = width
            cell.myMessageTextView.layer.cornerRadius = 10
            cell.partnersMessageTextView.text = messages[indexPath.row].message
            cell.partnerTimeLabel.text = "\(messages[indexPath.row].time.prefix(2)):\(messages[indexPath.row].time.suffix(2))"


        }
        
        return cell
    }
    private func estimateFrameForTextView(text:String) -> CGRect{
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14)], context: nil)
    }
    
}
extension ChatViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        sendButtonIsEnabled()
    }
}
