//
//  MainVC.swift
//  Exercise
//
//  Created by dvir on 14/01/2019.
//  Copyright © 2019 dvir. All rights reserved.
//

import Charts
import CoreData
import UIKit

class MainVC: UIViewController {
    
    //MARK: Injected Views Declaration
    @IBOutlet weak var chart: BarChartView!
    
    //MARK: Injected Views Actions
    @IBAction func openSettings(_ sender: UIButton) {
        self.present(settingsAlert,animated: true, completion: nil)
    }
    
    //MARK: Variables Declaration
    var settingsAlert: UIAlertController!
    var observer: NSObjectProtocol!
    var chartSettingsVC: ChartSettingsVC!
    let precisionOfChart: Double = 1800 //Precision by seconds.

    var barWidth: Double{
        return 0.3 * precisionOfChart
    }
    
    //MARK: ViewController Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsAlertInit()
        chartInit()
        updateChart()
        AppAuthentication.shared.deleteDelegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(showChartSettingsVC))
        
    }
    
    //Register to refreshChart event.
    override func viewDidAppear(_ animated: Bool) {
        observer = NotificationCenter.default.addObserver(forName: .refreshChart, object: nil, queue: OperationQueue.main) { (notification) in
            self.updateChart()
        }
    }
    
    //Unregister from refreshChart event.
    override func viewDidDisappear(_ animated: Bool) {
        if let observer = observer{
            NotificationCenter.default.removeObserver(observer)
        }
    }

    //MARK: Methods
    //Initializing chartView.
    private func chartInit(){
        chart.noDataText = "Please add some weather forecasts"
        chart.chartDescription?.text = ""
        
        let xaxis = chart.xAxis
        xaxis.drawGridLinesEnabled = true
        xaxis.labelPosition = .bottom
        xaxis.centerAxisLabelsEnabled = true
        xaxis.valueFormatter = self
        
        xaxis.granularity = precisionOfChart
    }
    
    //Populating the chart with data.
    private func updateChart(){
        let forecastsArray = CoreDataQueries.fetchSortedForecasts(ascending: true)
        
        if forecastsArray.isEmpty{
            return
        }
        
        var temperatureEntries : [BarChartDataEntry] = []
        var humidityEntries : [BarChartDataEntry] = []
        
        for i in 0..<forecastsArray.count {
            let temperatureEntry = BarChartDataEntry(x:forecastsArray[i].date + precisionOfChart * 0.25, y: forecastsArray[i].temperature)
            temperatureEntries.append(temperatureEntry)
            
            let humidityEntry = BarChartDataEntry(x:forecastsArray[i].date + precisionOfChart * 0.75, y: forecastsArray[i].humidity)
            humidityEntries.append(humidityEntry)
        }
        
        let temperatureDataSet = BarChartDataSet(values: temperatureEntries, label: "Temperature")
        temperatureDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        
        let humidityDataSet = BarChartDataSet(values: humidityEntries, label: "Humidity")
        
        let chartData = BarChartData(dataSets:[temperatureDataSet,humidityDataSet] )
        
        chartData.barWidth = barWidth;
        chart.xAxis.axisMinimum = forecastsArray.first!.date
        chart.xAxis.axisMaximum = forecastsArray.last!.date + precisionOfChart
        chart.notifyDataSetChanged()
        
        createChartSettingsVC(min: forecastsArray.first!.date, max: forecastsArray.last!.date)
        
        chart.data = chartData
    }
    
    //Shows the ChartSettingsVC.
    @objc private func showChartSettingsVC(){
        if !chart.isEmpty(){
            self.present(chartSettingsVC, animated: true, completion: nil)
        }else{
            self.present(populateFirstAlert(), animated: true, completion: nil)
        }
    }
    
    //Creates ChartSettingsVC.
    private func createChartSettingsVC(min:Double, max:Double){
        let sb = UIStoryboard(name: "Main", bundle: nil)
        chartSettingsVC = sb.instantiateViewController(withIdentifier: "chartsettings") as! ChartSettingsVC
        chartSettingsVC.min = min
        chartSettingsVC.max = max
        chartSettingsVC.modalPresentationStyle = .overCurrentContext
        chartSettingsVC.delegate = self
    }
    
    //Initializing settingsAlert.
    private func settingsAlertInit(){
        settingsAlert = UIAlertController(title: "Settings", message: nil, preferredStyle: .alert)
        
        //Delete User Action
        settingsAlert.addAction(UIAlertAction(title: "Delete User", style: .destructive, handler: { (action) in
            AppAuthentication.shared.deleteUser()
        }))
        
        //Logout Action
        settingsAlert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { (action) in
            AppAuthentication.shared.logout()
            self.performSegue(withIdentifier: "gotologin", sender: nil)
        }))
        
        settingsAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    }
    
    //Returns the populateFirst Alert.
    private func populateFirstAlert()->UIAlertController{
        let alert = UIAlertController(title: "Error", message: "Populate the chart first!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        return alert
    }
}

//Format the double(TimeInterval) to String(Date + Time).
extension MainVC: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy HH:mm"
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

extension MainVC: DeleteAuthDelegate{
    func onSuccessDelete() {
        self.performSegue(withIdentifier: "gotologin", sender: nil)
    }
    
    func onFailedDelete() {}
    
}

extension MainVC: ChartSettingsDelegate{
    
    func updateMinMax(min: Double, max: Double) {
        chart.xAxis.axisMinimum = min
        chart.xAxis.axisMaximum = max + precisionOfChart//(plus precisionOfChart) means inclusive
        chart.notifyDataSetChanged()
    }
    
}
