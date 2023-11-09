//
//  ChatRoomVC.swift
//  Chat Application
//
//  Created by ReMoSTos on 07/11/2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

class ChatRoomVC: UIViewController {
    
    //MARK: properties
    var room: Room?
    var chatMessageArr: [Message] = []
    
    //MARK: outlets
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var chatTableView: UITableView!
    
    //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableView.dataSource = self
        chatTableView.delegate = self
        
        title = room?.roomName
//        self.navigationController?.title = room?.roomName
        observeMessages()
    }
    //MARK: functions
    
    func observeMessages(){
        guard let roomId = room?.roomId else {
            return
        }
        let ref = Database.database().reference()
        let  room = ref.child("RoomName").child(roomId).child("Msg").observe(.childAdded) { data in
            if let dataArr = data.value as? [String: Any]{
                guard let senderName = dataArr["sendername"] as? String, let message = dataArr["message"] as? String, let userId = dataArr["senderId"] as? String else{
                    return
                }
                let messageDetails: Message = Message(messageKey: data.key , message: message, sendername: senderName, userId: userId)
                self.chatMessageArr.append(messageDetails)
                self.chatTableView.reloadData()

            }
        }
    }
    
    func getUserName(id: String, completion:@escaping (_ userName: String?) -> ()){
        let ref = Database.database().reference()
        let user = ref.child("user").child(id)
        user.child("userName").observeSingleEvent(of: .value) { data in
            if let username = data.value as? String {
                completion(username)
            }else{
                completion(nil)
            }
        }
    }
    
    func sendMessage(_ messageText: String, completion:@escaping (_ isSuccess: Bool) -> ()){
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference()
        getUserName(id: userId) { userName in
            if let username = userName{
                if let roomId = self.room?.roomId, let senderId = Auth.auth().currentUser?.uid{
                    let dataArr: [String: Any] = ["sendername": username, "message": messageText, "senderId": senderId]
                    
                    let room = ref.child("RoomName").child(roomId)
                    room.child("Msg").childByAutoId().setValue(dataArr) { error, databaseReference in
                        if error == nil{
                            completion(true)
                            self.messageTextField.text = ""
                        }else{
                            completion(false)
                        }
                    }
                }
            }
        }
    }
    
    
    //MARK: Actions
    @IBAction func sendMsgBtnClicked(_ sender: UIButton) {
        guard let chatText = self.messageTextField.text, chatText.isEmpty == false else{
            return
        }
        self.sendMessage(chatText) { isSuccess in
            if isSuccess {
                print("message send successfuly")
            }else{
                print("message not send")
            }
        }
    }
}

//MARK: Extention

extension ChatRoomVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatMessageArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
        let messageDetail = chatMessageArr[indexPath.row]
//        cell.senderNameLabel.text = messageDetail.sendername
//        cell.messageTextView.text = messageDetail.message
        cell.handelMessage(message: messageDetail)
        if messageDetail.userId == Auth.auth().currentUser?.uid{
            cell.handleMsgType(type: .outcoming)
        }else{
            cell.handleMsgType(type: .incoming)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        100
//    }
    
}

