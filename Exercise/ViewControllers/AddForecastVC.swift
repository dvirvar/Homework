//
//  AddForecastVC.swift
//  Exercise
//
//  Created by dvir on 14/01/2019.
//  Copyright © 2019 dvir. All rights reserved.
//

import CoreData
import UIKit

class AddForecastVC: UIViewController {

    //MARK: Injected Views Declaration
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var temperatureTF: UITextField!
    @IBOutlet weak var humidityTF: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var temperatureView: UIView!
    @IBOutlet weak var humidityView: UIView!
    
    //MARK: Injected Views Actions
    @IBAction func temperatureChanged(_ sender: UITextField) {
        var temperature = Double(sender.text!) ?? minTemperature
        
        if temperature < minTemperature{
            sender.text = minTemperature.description //<-Not good when minTemperature is a signed number.
            temperature = minTemperature
        }else if temperature > maxTemperature{
            sender.text = maxTemperature.description //<-Not good when maxTemperature is an unsigned number.
            temperature = maxTemperature
        }
        
        temperatureGauge.currentValue = CGFloat(temperatureFixer(temp: temperature))
        
    }
    
    @IBAction func humidityChanged(_ sender: UITextField) {
        var humidity = Double(sender.text!) ?? minHumidity
        
        if humidity < minHumidity{
            sender.text = minHumidity.description //<-Not good when minHumidity is a signed number.
            humidity = minHumidity
        }else if humidity > maxHumidity{
            sender.text = maxHumidity.description //<-Not good when maxHumidity is an unsigned number.
            humidity = maxHumidity
        }
        
        humidityGauge.currentValue = CGFloat(humidity)
        
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func saveData(_ sender: UIButton) {
        if temperatureTF.text!.isEmpty || humidityTF.text!.isEmpty{
            self.present(emptyTFAlert, animated: true, completion:nil)
            return
        }
        
        guard let temp = Double(temperatureTF.text!) else {
            self.present(mustBeAlert(textFieldName: "Temperature"), animated: true)
            return
        }
        
        guard let humidity = Double(humidityTF.text!) else {
            self.present(mustBeAlert(textFieldName: "Humidity"), animated: true)
            return
        }

        let date = datePicker.clampedDate.timeIntervalSince1970
        
        let forecastArray = CoreDataQueries.fetchForecast(date:date)
        
        //If not empty it means that forecast already exist.
        if !forecastArray.isEmpty{
            self.present(forecastExistAlert(forecast: forecastArray[0],temp: temp,humidity: humidity),animated: true,completion: nil)
            return
        }
        let weatherForecastEntity =
            NSEntityDescription.entity(forEntityName: "WeatherForecast",
                                       in: context)!
        
        let forecast = NSManagedObject(entity: weatherForecastEntity,
                                   insertInto: context)
        
        forecast.setValue(temp, forKey: "temperature")
        forecast.setValue(humidity, forKey: "humidity")
        forecast.setValue(date, forKey: "date")
        forecast.setValue(UUID(), forKey: "id")
        forecast.setValue(AppAuthentication.shared.getCurrentUserUUID(), forKey:"userID" )
        
        do{
            try context.save()
            NotificationCenter.default.post(name: .refreshChart, object: nil)
            dismiss(animated: true)
        }catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: Variables Declaration
    var emptyTFAlert: UIAlertController!
    var temperatureGauge: GDGaugeView!
    var humidityGauge: GDGaugeView!
    let minTemperature: Double = -10
    let maxTemperature: Double = 50
    let minHumidity: Double = 0
    let maxHumidity: Double = 100
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: ViewController Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpView.layer.cornerRadius = 10
        emptyTFAlertInit()
        temperatureGaugeInit()
        humidityGaugeInit()
    }
    
    //MARK: Methods
    //GDGuageView cant do a proper calculation with minus numbers in the min.
    //Had to calculate so it will show the temperature properly.
    private func temperatureFixer(temp:Double)->Double{
        var fixedTemperature = temp
        fixedTemperature -= minTemperature
        fixedTemperature /= (maxTemperature - minTemperature)/maxTemperature
        return fixedTemperature
    }
    
    //Initializing temperatureGauge
    private func temperatureGaugeInit(){
        temperatureGauge = GDGaugeView(frame: temperatureView.bounds)
        temperatureGauge.min = CGFloat(minTemperature)
        temperatureGauge.max = CGFloat(maxTemperature)
        temperatureGauge.stepValue = 10
        temperatureGauge.currentValue = CGFloat(temperatureFixer(temp: minTemperature))
        temperatureGauge.unitText = "C°"
        temperatureView.addSubview(temperatureGauge)
        temperatureGauge.setupView()
    }
    
    //Initializing huimidityGuage
    private func humidityGaugeInit(){
        humidityGauge = GDGaugeView(frame: humidityView.bounds)
        humidityGauge.min = CGFloat(minHumidity)
        humidityGauge.max = CGFloat(maxHumidity)
        humidityGauge.currentValue = CGFloat(minHumidity)
        humidityGauge.unitText = "RH%"
        humidityView.addSubview(humidityGauge)
        humidityGauge.setupView()
    }
  
    //Initializing emptyTFAlert.
    private func emptyTFAlertInit(){
        emptyTFAlert = UIAlertController(title: "Error", message: "Temperature/Humidity can not be empty", preferredStyle: .alert)
        emptyTFAlert.addAction(UIAlertAction(title: "Ok", style: .cancel))
    }
    
    //Must be a number Alert.
    private func mustBeAlert(textFieldName:String)->UIAlertController{
        let alert = UIAlertController(title: "Error", message: "\(textFieldName) must be a number", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        return alert
    }
    
    //Returns the forecastExist alert,
    private func forecastExistAlert(forecast:WeatherForecast,temp:Double,humidity:Double)->UIAlertController{
        let alert = UIAlertController(title: "Forecast Exist", message: "Would you like to update forecast?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.updateForecast(forecast: forecast, temp: temp, humidity: humidity)
            self.dismiss(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        return alert
    }
    
    //Updating forecast
    private func updateForecast(forecast:WeatherForecast,temp:Double,humidity:Double){
        forecast.setValue(temp, forKey: "temperature")
        forecast.setValue(humidity, forKey: "humidity")
        
        do{
            try context.save()
            NotificationCenter.default.post(name: .refreshChart, object: nil)
        }catch let error as NSError{
            print("Could not update due to \(error.localizedDescription)")
        }
    }

}
