//
//  Utilities.swift
//  Exercise
//
//  Created by dvir on 18/01/2019.
//  Copyright © 2019 dvir. All rights reserved.
//

import CoreData
import UIKit

class CoreDataQueries{
    private static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private static let userDefaults = UserDefaults.standard
    
    //MARK: User Queries
    //Fetches current user.
    static func fetchCurrentUser()->User?{
        let fetchRequest : NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", AppAuthentication.shared.getCurrentUserID()!)
        
        do{
            return try context.fetch(fetchRequest)[0]
        }catch let error as NSError{
            print("Could not fetch due to \(error.localizedDescription)")
        }
        return nil
    }
    
    //Fetches User by his username.
    static func fetchUserByName(username:String)->User?{
        let fetchRequest :  NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@", username)
        
        do{
            return try context.fetch(fetchRequest).first
        }catch{
            print("Error while fetching user")
        }
        return nil
    }
    
    //MARK: Weatherforecast Queries
    //Fetches WeatherForecast of current user by date.
    static func fetchForecast(date:Double)->[WeatherForecast]{
        let fetchRequest: NSFetchRequest<WeatherForecast> = WeatherForecast.fetchRequest()
        
        let datePredicate = NSPredicate(format: "date == %@", date.description)
        let userIDPredicate = NSPredicate(format: "userID == %@", AppAuthentication.shared.getCurrentUserID()!)
        
        let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, userIDPredicate])
        
        fetchRequest.predicate = andPredicate
        
        do{
            return try context.fetch(fetchRequest)
        }catch let error as NSError{
            print("Could not fetch due to \(error.localizedDescription)")
        }
        return [WeatherForecast]()
    }
    
    //Fetches all WeatherForecasts of the current user.
    static func fetchForecasts()->[WeatherForecast]{
        let fetchRequest: NSFetchRequest<WeatherForecast> = WeatherForecast.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userID == %@", AppAuthentication.shared.getCurrentUserID()!)
        
        do{
            return try context.fetch(fetchRequest)
        }catch let error as NSError{
            print("Could not fetch due to \(error.localizedDescription)")
        }
        return [WeatherForecast]()
    }
    
    //Fetches all WeatherForcasts of the current user sorted.
    static func fetchSortedForecasts(ascending:Bool)->[WeatherForecast]{
        let fetchRequest :  NSFetchRequest<WeatherForecast> = WeatherForecast.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userID == %@", AppAuthentication.shared.getCurrentUserID()!)
        
        let sort = NSSortDescriptor(key: "date", ascending: ascending)
        fetchRequest.sortDescriptors = [sort]
        
        do{
            return try context.fetch(fetchRequest)
        }catch let error as NSError{
            print("Could not fetch due to \(error.localizedDescription)")
        }
        return [WeatherForecast]()
    }
    
    //MARK: Network Queries
    //Fetches network by name and password.
    static func fetchNetwork(name:String, password:String)->[Network]{
        let fetchRequest: NSFetchRequest<Network> = Network.fetchRequest()
        
        let namePredicate = NSPredicate(format: "name == %@", name)
        let passwordPredicate = NSPredicate(format: "password == %@", password)
        let userIDPredicate = NSPredicate(format: "userID == %@", AppAuthentication.shared.getCurrentUserID()!)
        
        let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, passwordPredicate,userIDPredicate])
        
        fetchRequest.predicate = andPredicate
        
        do{
            return try context.fetch(fetchRequest)
        }catch let error as NSError{
            print("Could not fetch due to \(error.localizedDescription)")
        }
        return [Network]()
    }
    
    //Fetches all Networks of the current user.
    static func fetchNetworks()->[Network]{
        let fetchRequest: NSFetchRequest<Network> = Network.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userID == %@", AppAuthentication.shared.getCurrentUserID()!)
        
        do{
            return try context.fetch(fetchRequest)
        }catch let error as NSError{
            print("Could not fetch due to \(error.localizedDescription)")
        }
        return [Network]()
    }
    
}
