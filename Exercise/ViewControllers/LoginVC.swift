//
//  LoginVC.swift
//  Exercise
//
//  Created by dvir on 14/01/2019.
//  Copyright © 2019 dvir. All rights reserved.
//

import CoreData
import UIKit

class LoginVC: UIViewController {

    //MARK: Injected Views Declaration
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    //MARK: Injected Views Actions
    @IBAction func login(_ sender: UIButton) {
        
        let username = usernameTF.text!
        let password = passwordTF.text!
        
        if username.isEmpty || password.isEmpty {
            self.present(emptyTFAlert!, animated: true, completion:nil)
            return
        }
        
        AppAuthentication.shared.login(username: username, password: password)
    }
    
    //MARK: Variables Declaration
    var emptyTFAlert : UIAlertController!
    var userDoesntExist : UIAlertController!
    var passwordIsWrong : UIAlertController!
    
    //MARK: ViewController Lifecyles
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyTFAlertInit()
        userDoesntExistInit()
        passwordIsWrongInit()
        AppAuthentication.shared.loginDelegate = self
    }
    
    //MARK: Methods
    //Initializing emptyTFAlert.
    private func emptyTFAlertInit(){
        emptyTFAlert = UIAlertController(title: "Error", message: "Username/Password can not be empty", preferredStyle: .alert)
        emptyTFAlert.addAction(UIAlertAction(title: "Ok", style: .cancel))
    }
    
    //Initializing userDoesntExist Alert.
    private func userDoesntExistInit(){
        userDoesntExist = UIAlertController(title: "Username Doesn't exist", message: "", preferredStyle: .alert)
        userDoesntExist.addAction(UIAlertAction(title: "Go Register", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "gotoregisterwithinfo", sender: self)
        }))
        userDoesntExist.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    }
    
    //Initializing passwordIsWrong Alert.
    private func passwordIsWrongInit(){
        passwordIsWrong = UIAlertController(title: "Wrong password", message: "", preferredStyle: .alert)
        passwordIsWrong.addAction(UIAlertAction(title: "Ok", style: .cancel))
    }
    
    //It conveys the usernameTF.text to usernameTF in RegisterCV.
    //It won't convey the password, Because maybe he did a mistake and,
    //Because we dont have password confirmation.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoregisterwithinfo"{
            if let nextVC = segue.destination as? RegisterVC{
                nextVC.prevUsername = usernameTF.text!
            }
        }
    }
    
}

extension LoginVC: LoginAuthDelegate{
    func onSuccessLogin() {
        performSegue(withIdentifier: "gotomain", sender: nil)
    }
    
    func onWrongUsername() {
        self.present(userDoesntExist!, animated: true, completion: nil)
    }
    
    func onWrongPassword() {
        self.present(passwordIsWrong!, animated: true, completion: nil)
    }
}
