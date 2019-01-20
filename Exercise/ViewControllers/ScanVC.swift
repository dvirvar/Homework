//
//  ScanVC.swift
//  Exercise
//
//  Created by dvir on 17/01/2019.
//  Copyright © 2019 dvir. All rights reserved.
//
import CoreData
import NetworkExtension
import UIKit

class ScanVC: UIViewController {
    //MARK: Injected Views
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Variables Declaration
    var connectAlert: UIAlertController!
    var emptySSIDAlert: UIAlertController!
    var failedToConnectAlert: UIAlertController!
    var successAlert: UIAlertController!
    var networkArray = [Network]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        connectAlertInit()
        emptySSIDAlertInit()
        failedToConnectAlertInit()
        successAlertInit()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Connect to wifi", style: .plain, target: self, action: #selector(showConnectAlert))
        navigationItem.title = "Wifi History"
        
        networkArray = CoreDataQueries.fetchNetworks()
        tableView.reloadData()
    }
    
    //MARK: Methods
    //Shows connectAlert.
    @objc private func showConnectAlert(){
        self.present(connectAlert,animated: true,completion: nil)
    }

    //Connects to a wifi network.
    private func connect(ssid:String,password:String){
        if ssid.isEmpty{
            self.present(emptySSIDAlert,animated:true,completion:nil)
            return
        }
        
        if TARGET_IPHONE_SIMULATOR == 0{
            if #available(iOS 11.0, *){
                let configuration = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: false)
                configuration.joinOnce = false
                
                NEHotspotConfigurationManager.shared.apply(configuration) { (error) in
                    if error != nil {
                        self.present(self.failedToConnectAlert, animated: true, completion: nil)
                        print(error!.localizedDescription)
                    }else {
                        self.present(self.successAlert,animated: true,completion:{self.saveNetwork(name: ssid,password: password)})
                    }
                }
            }
        }else{
            print("Not working on simulator")
        }
    }
    
    //Saves the network data in core data.
    private func saveNetwork(name:String, password:String){
        //Checks if network already exist.
        let tempNet = CoreDataQueries.fetchNetwork(name: name, password: password)
        if !tempNet.isEmpty{
            moveNetworkToTop(network: tempNet.first!)
            return
        }
        
        let networkEntity =
            NSEntityDescription.entity(forEntityName: "Network",
                                       in: context)!
        
        let network = NSManagedObject(entity: networkEntity,
                                   insertInto: context)
        
        network.setValue(name, forKey: "name")
        network.setValue(password, forKey: "password")
        network.setValue(UUID(), forKey: "id")
        network.setValue(AppAuthentication.shared.getCurrentUserUUID(), forKey: "userID")
        
        do {
            try context.save()
            addNetworkToHistory(network: network as! Network)
        }catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //Adds the network object to the tableView at index 0.
    private func addNetworkToHistory(network:Network){
        networkArray.insert(network, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
    }
    
    //Moves an exist network to index 0 of tableView.
    private func moveNetworkToTop(network:Network){
        guard let index = networkArray.index(of: network) else{
            return
        }
        tableView.beginUpdates()
        let at = IndexPath(row: index, section: 0)
        let to = IndexPath(row: 0, section: 0)
        tableView.moveRow(at: at, to: to)
        networkArray.remove(at: index)
        networkArray.insert(network, at: 0)
        tableView.endUpdates()
    }
    
    //Initializing connectAlert.
    private func connectAlertInit(){
        connectAlert = UIAlertController(title: "Connect", message: "", preferredStyle: .alert)
        connectAlert.addTextField { (textField) in
            textField.placeholder = "SSID"
        }
        connectAlert.addTextField { (textField) in
            textField.placeholder = "Password"
        }
        connectAlert.addAction(UIAlertAction(title: "Connect", style: .default, handler: { (action) in
            let ssid = self.connectAlert.textFields![0].text!
            let password = self.connectAlert.textFields![1].text!
            self.connect(ssid: ssid,password: password)
        }))
        connectAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    }
    
    //Initializing emptySSIDAlert.
    private func emptySSIDAlertInit(){
        emptySSIDAlert = UIAlertController(title: "Error", message: "Please enter SSID", preferredStyle: .alert)
        emptySSIDAlert.addAction(UIAlertAction(title: "Ok", style: .cancel))
    }
    
    //Initializing failedToConnectAlert.
    private func failedToConnectAlertInit(){
        failedToConnectAlert = UIAlertController(title: "Failed To Connect", message: "", preferredStyle: .alert)
        failedToConnectAlert.addAction(UIAlertAction(title: "Ok", style: .cancel))
    }
    
    //Initializing successAlert.
    private func successAlertInit(){
        successAlert = UIAlertController(title: "Success", message: "Connected successfully", preferredStyle: .alert)
        successAlert.addAction(UIAlertAction(title: "Ok", style: .default))
    }

}

//MARK: TableView Delegate + DataSource extention.
extension ScanVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networkArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = networkArray[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedNetwork = networkArray[indexPath.row]
        let name = selectedNetwork.name!
        let password = selectedNetwork.password!
        self.present(askAlert(name: name, password: password),animated: true,completion: nil)
    }
    
    private func askAlert(name:String,password:String)->UIAlertController{
        let alert = UIAlertController(title: "Connect?", message: "Would you like to try to connect to \(name)?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.connect(ssid: name, password: password)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        return alert
    }
    
}
