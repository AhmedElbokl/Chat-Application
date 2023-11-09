//
//  ChatCellTableViewCell.swift
//  Chat Application
//
//  Created by ReMoSTos on 09/11/2023.
//

import UIKit
import SwiftUI

class ChatCell: UITableViewCell {
    
    //MARK: Properties
    enum messageType{
        case incoming
        case outcoming
    }

    //MARK: outlets
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 15
    }
    
    func handelMessage(message: Message){
        self.senderNameLabel.text = message.sendername
        self.messageTextView.text = message.message
    }
    
    func handleMsgType(type: messageType){
        switch type{
        case .incoming:
            containerStackView.alignment = .leading
            messageTextView.textColor = .black
            containerView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        case .outcoming:
            containerStackView.alignment = .trailing
            messageTextView.textColor = .white
            containerView.backgroundColor = #colorLiteral(red: 0, green: 0.2784313725, blue: 0.3568627451, alpha: 1)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
