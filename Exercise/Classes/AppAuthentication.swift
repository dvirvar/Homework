//
//  AppAuthentication.swift
//  Exercise
//
//  Created by dvir on 19/01/2019.
//  Copyright © 2019 dvir. All rights reserved.
//

import CoreData
import UIKit

class AppAuthentication {
    //Singleton
    public static let shared = AppAuthentication()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var userEntity: NSEntityDescription!
    var registerDelegate: RegisterAuthDelegate?
    var loginDelegate: LoginAuthDelegate?
    var deleteDelegate: DeleteAuthDelegate?
    
    private init() {
        userEntity = NSEntityDescription.entity(forEntityName: "User",
                                                in: context)!
    }
    
    //Fetches user id.
    func getCurrentUserID()->String?{
        return UserDefaults.standard.string(forKey: "uuid")
    }
    
    //Fetches user uuid.
    func getCurrentUserUUID()->UUID{
        return UUID(uuidString: getCurrentUserID()!)!
    }
    
    //Saves the uuid to UserDefaults.(for login)
    func saveUser(uuid:String){
        UserDefaults.standard.set(uuid, forKey: "uuid")
    }
    
    //Removes the uuid from UserDefaults.(for logout)
    func removeUser(){
        UserDefaults.standard.set(nil, forKey: "uuid")
    }
    
    //Registers the user to the core data.
    func register(username:String, password:String){
        if CoreDataQueries.fetchUserByName(username: username) != nil{
            registerDelegate?.onUsernameIsTaken()
            return
        }
        
        let user = NSManagedObject(entity: userEntity,
                                   insertInto: context)
        
        let uuid = UUID()
        
        user.setValue(username, forKeyPath: "username")
        user.setValue(password, forKeyPath: "password")
        user.setValue(uuid, forKeyPath: "id")
        
        do {
            try context.save()
            saveUser(uuid: uuid.uuidString)
            registerDelegate?.onSuccessRegister()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            registerDelegate?.onFailedRegister()
        }
    }
    
    //If Logged in successfully, saves the id of the user to UserDefaults.
    func login(username:String, password:String){
        
        guard let user = CoreDataQueries.fetchUserByName(username: username) else{
            loginDelegate?.onWrongUsername()
            return
        }
        
        if user.password! != password{
            loginDelegate?.onWrongPassword()
            return
        }
        
        saveUser(uuid: user.id!.uuidString)
        loginDelegate?.onSuccessLogin()
    }
    
    //Removes the id of the user from UserDefaults.
    func logout(){
        removeUser()
    }
    
    //Deletes the user and all his "belongings" from core data.
    func deleteUser(){
        let weatherForecasts = CoreDataQueries.fetchForecasts()
        for forecast in weatherForecasts{
            context.delete(forecast) //Could use relationships in core data with cascade and that could be avoided
        }
        
        let networks = CoreDataQueries.fetchNetworks()
        for network in networks{
            context.delete(network)//Could use relationships in core data with cascade and that could be avoided
        }
        
        context.delete(CoreDataQueries.fetchCurrentUser()!)
        
        do{
            try context.save()
            logout()
            deleteDelegate?.onSuccessDelete()
        }catch let error as NSError{
            print("Could not save due to \(error.localizedDescription)")
            deleteDelegate?.onFailedDelete()
        }
    }
}
