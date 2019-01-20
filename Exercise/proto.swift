//
//  proto.swift
//  Exercise
//
//  Created by dvir on 19/01/2019.
//  Copyright © 2019 dvir. All rights reserved.
//

import Foundation

protocol PP {
    
    func onSuccessLogin()
    func onFailedLogin()
    func onSuccessRegister()
    func onFailedRegister()
    func onUsernameIsTaken()
}
