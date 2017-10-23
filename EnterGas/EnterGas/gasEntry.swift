//
//  gasEntry.swift
//  EnterGas
//
//  Created by John Burgess on 10/22/17.
//  Copyright © 2017 JTBURGESS. All rights reserved.
//

import UIKit

public class gasEntry: NSObject {
    var vendor: String
    var date: Date
    var odometer: Int
    var cost: Decimal
    var gallons: Decimal
    
    public init (vendor:String, dateString:String, odometer:Int, cost:Decimal, gallons:Decimal) {
        self.vendor = vendor
        self.date = (toDate(from:dateString) ?? nil)!
        self.odometer = odometer
        self.cost = cost
        self.gallons = gallons
    }
}

fileprivate func toDate(from:String) -> Date? {
    let myDateFormatter = DateFormatter()
    myDateFormatter.dateFormat = "MM-dd-yyyy"
    myDateFormatter.locale = Locale(identifier: "en_US")
    return myDateFormatter.date(from:from)
}
