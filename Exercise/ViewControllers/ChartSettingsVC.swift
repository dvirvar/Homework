//
//  ChartSettingsVC.swift
//  Exercise
//
//  Created by dvir on 20/01/2019.
//  Copyright © 2019 dvir. All rights reserved.
//

import UIKit

class ChartSettingsVC: UIViewController {
    //MARK: Injected Views Declaration
    @IBOutlet var datePickers: [UIDatePicker]!
    @IBOutlet weak var popUpView: UIView!
    
    //MARK: Injected Views Actions
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func reset(_ sender: UIButton) {
        delegate?.updateMinMax(min: min, max: max)
        resetDates()
        dismiss(animated: true)
    }
    
    @IBAction func save(_ sender: UIButton) {
        let firstDate = datePickers[0].clampedDate.timeIntervalSince1970
        let secondDate = datePickers[1].clampedDate.timeIntervalSince1970
        
        if firstDate == secondDate{
            self.present(cantBeTheSameAlert, animated: true, completion: nil)
            return
        }
        
        if firstDate > secondDate{
            delegate?.updateMinMax(min: secondDate, max: firstDate)
        }else{
            delegate?.updateMinMax(min: firstDate, max: secondDate)
        }
        dismiss(animated: true)
    }
    
    //MARK: Variables Declaraion
    var cantBeTheSameAlert: UIAlertController!
    var delegate: ChartSettingsDelegate?
    var min:Double!
    var max:Double!
    
    //MARK: ViewController Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpView.layer.cornerRadius = 10
        resetDates()
        cantBeTheSameInit()
    }
    
    //MARK: Methods
    //Resets the timePickers to the min and max values.
    private func resetDates(){
        datePickers[0].setDate(Date(timeIntervalSince1970: min), animated: false)
        datePickers[1].setDate(Date(timeIntervalSince1970: max), animated: false)
    }
    
    //Initializing cantBeTheSameAlert.
    private func cantBeTheSameInit(){
        cantBeTheSameAlert =  UIAlertController(title: "Error", message: "Dates can not be the same", preferredStyle: .alert)
        cantBeTheSameAlert.addAction(UIAlertAction(title: "Ok", style: .default))
    }


}
