//
//  HomeVC.swift
//  Chat Application
//
//  Created by ReMoSTos on 07/11/2023.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth

class HomeVC: UIViewController {
    
    //MARK: properties
    var roomArr: [Room] = []
    //MARK: layouts
    @IBOutlet weak var chatRoomNameTextField: UITextField!
    @IBOutlet weak var roomsTableView: UITableView!
    
    //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        roomsTableView.dataSource = self
        roomsTableView.delegate = self
        
        observeChatRooms()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser == nil {
            goToRegisterVC()
        }
    }
    
    
//MARK: Functions
    func goToRegisterVC(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let registerVC = mainStoryboard.instantiateViewController(withIdentifier: "RegisterVC")
        registerVC.modalPresentationStyle = .fullScreen
        self.present(registerVC, animated: true)
    }
    
    func observeChatRooms(){
        let ref = Database.database().reference()
        ref.child("RoomName").observe(.childAdded) { addedRoom in
            if let dataArr = addedRoom.value as? [String: Any]{
                if let roomName = dataArr["roomName"] as? String {
                    let room = Room(roomId: addedRoom.key, roomName: roomName)
                    self.roomArr.append(room)
                    self.roomsTableView.reloadData()
                }
            }
        }
    }
    
    //MARK: Actions
    @IBAction func logoutBtnClicked(_ sender: Any) {
        try! Auth.auth().signOut()
        goToRegisterVC()
    }
    
    @IBAction func createRoomBtnClicked(_ sender: Any) {
        guard let roomName = chatRoomNameTextField.text, roomName.isEmpty == false else {
            return
        }
        
        let ref = Database.database().reference()
        let room = ref.child("RoomName").childByAutoId()
        
        let dataArr = ["roomName": roomName]
        room.setValue(dataArr) { error, DatabaseReference in
            if error == nil {
                self.chatRoomNameTextField.text = ""
                print("data send to database successfuly")
            }else{
                print(error!)
            }
        }
    }
    

}

//MARK: Extentions
extension HomeVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        roomArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell")!
        let room = roomArr[indexPath.row]
        cell.textLabel?.text = room.roomName
        cell.textLabel?.font = .init(name: "Impact" , size: 40)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedRoom = roomArr[indexPath.row]
        let chatRoomVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatRoomVC") as! ChatRoomVC
        chatRoomVC.room = selectedRoom
        self.navigationController?.pushViewController(chatRoomVC, animated: true)
    }
    
}
