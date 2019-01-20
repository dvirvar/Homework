//
//  AuthenticationDelegate.swift
//  Exercise
//
//  Created by dvir on 19/01/2019.
//  Copyright © 2019 dvir. All rights reserved.
//

import Foundation

protocol LoginAuthDelegate{
    
    func onSuccessLogin()
    func onWrongUsername()
    func onWrongPassword()
    
}
