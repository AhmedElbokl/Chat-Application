//
//  ViewController.swift
//  Chat Application
//
//  Created by ReMoSTos on 06/11/2023.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth

class RegisterVC: UIViewController {
    
    //MARK: properties
    
    
    //MARK: Outlets
    @IBOutlet weak var containerCollectionView: UICollectionView!
    
    //MARK: lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerCollectionView.dataSource = self
        containerCollectionView.delegate = self
        
        
    }
    //MARK: Method
    
    func displayError(_ errorText: String){
        let alert = UIAlertController(title: "Error", message: errorText, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "dismiss", style: .default)
        alert.addAction(dismissAction)
        self.present(alert, animated: true)
    }
    
    @objc func slideToSignIn(){
        let indexPath = IndexPath(row: 1, section: 0)
        self.containerCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    @objc func slideToSignUp(){
        self.containerCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    @objc func signUpBtnClicked(){
        var userName: String = ""
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = containerCollectionView.cellForItem(at: indexPath) as! FormCell
        
        guard let email = cell.emailTextField.text, let password = cell.passwordTextField.text else{
            return
        }
        if let name = cell.userNameTextField.text {
            userName = name
        }
        if email.isEmpty || password.isEmpty || userName.isEmpty {
            self.displayError("Enter Fields Data")
        }else{
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if error == nil {
                    guard let userId = authResult?.user.uid else{
                        return
                    }
                    let ref = Database.database().reference()
                    let user = ref.child("user").child(userId)
                    let dataArr: [String: Any] = ["userName": userName/*, "": , "": , ....*/]
                    user.setValue(dataArr)
                    self.dismiss(animated: true)
                }else {
                    self.displayError("Wrong Input Data")
                }
            }
        }
    }
    
    @objc func logInBtnClicked(){
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = containerCollectionView.cellForItem(at: indexPath) as! FormCell
        
        guard let email = cell.emailTextField.text, let password = cell.passwordTextField.text else{
            return
        }
        if email.isEmpty || password.isEmpty {
            self.displayError("Enter Fields Data")
        }else{
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard self != nil else { return }
                // ...
                if error == nil{
                    guard let authResult = authResult else {
                        return
                    }
                    print(authResult)
                    self?.dismiss(animated: true)
                }else{
                    self?.displayError("Wrong Input Data")
                }
            }
        }

    }
    //MARK: Action
    
    
}

//MARK: Extension
extension RegisterVC: UICollectionViewDataSource ,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FormCell", for: indexPath) as! FormCell
        
        if indexPath.row == 0 {
            cell.userNameTextField.isHidden = true
            cell.mainBtn.setTitle("Login", for: .normal)
            cell.slideBtn .setTitle("Sing Up", for: .normal)
            
            cell.slideBtn.addTarget(self, action: #selector(slideToSignIn), for: .touchUpInside)
            cell.mainBtn.addTarget(self, action: #selector(logInBtnClicked), for: .touchUpInside)
            
        }else{
            cell.userNameTextField.isHidden = false
            cell.mainBtn.setTitle("Sign Up", for: .normal)
            cell.slideBtn.setTitle("Sign In", for: .normal)
            
            cell.slideBtn.addTarget(self, action: #selector(slideToSignUp), for: .touchUpInside)
            cell.mainBtn.addTarget(self, action: #selector(signUpBtnClicked), for: .touchUpInside)
            
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
}
