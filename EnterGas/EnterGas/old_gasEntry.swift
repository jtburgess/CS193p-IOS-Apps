//
//  gasEntry.swift
//  EnterGas
//
//  Created by John Burgess on 10/22/17.
//  Copyright © 2017 JTBURGESS. All rights reserved.
//

import UIKit
import CoreData

class old_GasEntry: NSObject  {
    var brand: String
    var date: Date
    var odometer: Int
    var cost: Decimal
    var amount: Decimal
    
    public init (brand:String,
                dateString:String,
                odometer:Int,
                cost:Decimal,
                amount:Decimal) {
        self.brand = brand
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "MM-dd-yyyy"
        myDateFormatter.locale = Locale(identifier: "en_US")
        self.date = (myDateFormatter.date(from:dateString) ?? nil)!
        self.odometer = odometer
        self.cost = cost
        self.amount = amount
    }
    public init (brand:String,
                pickedDate:UIDatePicker,
                odometer:Int,
                cost:Decimal,
                amount:Decimal) {
        self.brand = brand
        self.date = pickedDate.date
        self.odometer = odometer
        self.cost = cost
        self.amount = amount
    }
}


