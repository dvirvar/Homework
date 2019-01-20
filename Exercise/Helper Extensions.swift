//
//  Helper Extensions.swift
//  Exercise
//
//  Created by dvir on 17/01/2019.
//  Copyright © 2019 dvir. All rights reserved.
//

import UIKit

extension UIDatePicker {
    
    //Removes the seconds and give the real date and time that the picker shows.
    public var clampedDate: Date {
        let referenceTimeInterval = self.date.timeIntervalSinceReferenceDate
        let remainingSeconds = referenceTimeInterval.truncatingRemainder(dividingBy: TimeInterval(minuteInterval*60))
        let timeRoundedToInterval = referenceTimeInterval - remainingSeconds
        return Date(timeIntervalSinceReferenceDate: timeRoundedToInterval)
    }
    
}

extension Notification.Name {
    static let refreshChart = Notification.Name("refreshChart")
}
