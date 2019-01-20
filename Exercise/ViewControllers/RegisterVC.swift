//
//  RegisterVC.swift
//  Exercise
//
//  Created by dvir on 14/01/2019.
//  Copyright © 2019 dvir. All rights reserved.
//

import CoreData
import UIKit

class RegisterVC: UIViewController {

    //MARK: Injected Views Declaration
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    //MARK: Injected Views actions
    @IBAction func register(_ sender: UIButton) {
        
        let username = usernameTF.text!
        let password = passwordTF.text!
        
        if username.isEmpty || password.isEmpty {
            self.present(emptyTFAlert!, animated: true, completion:nil)
            return
        }
        
        AppAuthentication.shared.register(username: username, password: password)
    }
    
    //MARK: Variables Declaration
    var emptyTFAlert: UIAlertController!
    var isTakenAlert: UIAlertController!
    var prevUsername = String()
    
    //MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyTFAlertInit()
        isTakenAlertInit()
        usernameTF.text = prevUsername //Comes from segue with identifier: gotoregisterwithinfo.
        AppAuthentication.shared.registerDelegate = self
        
    }
    
    //MARK: Methods
    //Initializing emptyTFAlert.
    private func emptyTFAlertInit(){
        emptyTFAlert = UIAlertController(title: "Error", message: "Username/Password can not be empty", preferredStyle: .alert)
        emptyTFAlert.addAction(UIAlertAction(title: "Ok", style: .cancel))
    }
    
    //Initializing isTakenAlert.
    private func isTakenAlertInit(){
        isTakenAlert = UIAlertController(title: "Error", message: "Username is already taken", preferredStyle: .alert)
        isTakenAlert.addAction(UIAlertAction(title: "Ok", style: .cancel))
    }
}

extension RegisterVC: RegisterAuthDelegate{
    func onSuccessRegister() {
        performSegue(withIdentifier: "gotomain", sender: nil)
    }
    
    func onFailedRegister() {}
    
    func onUsernameIsTaken() {
        self.present(isTakenAlert!, animated: true, completion:nil)
    }
}
