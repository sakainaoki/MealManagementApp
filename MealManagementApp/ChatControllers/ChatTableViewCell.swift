//
//  ChatTableViewCell.swift
//  MealManagementApp
//
//  Created by 酒井直輝 on 2021/07/30.
//

import UIKit
import Firebase
class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var partnerImageView: UIImageView!
    @IBOutlet weak var partnerTimeLabel: UILabel!
    @IBOutlet weak var partnersMessageTextView: UITextView!
    @IBOutlet weak var myMessageTextView: UITextView!
    @IBOutlet weak var myTimeLabel: UILabel!
    
    @IBOutlet weak var partnersMessageTextViewWidth: NSLayoutConstraint!
    @IBOutlet weak var myMessageTextViewWidth: NSLayoutConstraint!
    var message: MessagesModel?{
        didSet {
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        partnerImageView.layer.cornerRadius = 30
        partnersMessageTextView.layer.cornerRadius = 15
        
        backgroundColor = .clear
        partnersMessageTextView.backgroundColor = UIColor.rgb(red: 72, green: 72, blue: 74)
        partnersMessageTextView.textColor = .white
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
