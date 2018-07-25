//
//  extensions.swift
//  EnterGas
//
//  Created by John Burgess on 2/25/18.
//  Copyright © 2018 JTBURGESS. All rights reserved.
//

import UIKit

// MARK: user preferences aka UserDefaults
let defaults = UserDefaults.standard

// all of the "current" values are not optional. I supply real defaults
let vehicleNameKey = "vehicleName"
var currentVehicle : String = ""

var theVehicle = vehicleData()

// keys for vehicleData
// original set was two variables - vehicle name and fuelTypeID
// new style is vehicle name and a dictionary by vehicle of:
//      fuelTypeID, cash_credit:Bool, partial_fill:Bool, min/TOT(*)/max MPG, min/TOT(*)/max dist/fillup
//      and calculated #entries (denominator to calc average)

// fuelTypeID WAS used as the index into fuelTypePickerValues for display purposes
let fuelTypeKey = "fuelType"
let cashCreditKey = "cashOrCredit"
let partialFillKey = "partialOrFillUp"
let brandKey = "brand"
let unitKey  = "unitType"

// prefix min,max,tot ...
let amtKey = "amount"
let distKey  = "distance"
let costKey  = "cost"
let countKey = "count"
let distPerUnitKey   = "distPerUnit"
let costPerUnitKey   = "costPerUnit"

// allow the various display strings to be localized to either the british or metric system of units
let unitLabels: [String:[String:String]] =
    [ "US": [
        "mpg" : "mpg"
        ],
      "metric": [
        "mpg" : "kpl"
        ]
    ]

func getDefaults() {
    print("TabBarDefaults did load")
}

class vehicleData: NSObject {
    var vehicleData: [String:NSNumber] = [:]

    override init() {
        super.init()
        if  let anyValue = defaults.object(forKey: vehicleNameKey),
            let tmp = anyValue as? String {
            currentVehicle = tmp
        } else {
            // need to assign a default vehicle - segue to that screen
            print("no default vehicle")
            return
        }

        if let tmp = defaults.object(forKey: currentVehicle) as? [String:NSNumber] {
            vehicleData = tmp
            print("loaded vehicle Data for \(currentVehicle): \(vehicleData)")
        } else {
            // get the old-style fuelID and convert
            if  let anyValue = defaults.object(forKey: fuelTypeKey),
                let tmp = anyValue as? NSNumber {
                self.set(key: fuelTypeKey, value: tmp)
                print("converted vehicle Data from \(currentVehicle): \(vehicleData)")
            } else {
                // need to assign a default fuel type - segue to that screen
                // for now default to regular
                self.set(key: fuelTypeKey, value: 0 as NSNumber)
                print ("no default fuel type")
            }
        }
        
    }
    func get (key:String) -> NSNumber? {
        return vehicleData[key]
    }
    func set (key:String, value:NSNumber) {
        vehicleData[key] = value
    }
    func save() {
        print("saving vehicle Data for \(currentVehicle): \(vehicleData)")
        defaults.setValue(vehicleData, forKey: currentVehicle)
    }
}
// MARK: my custom format classes and global vars
let myDate: MyDate = MyDate()
let myCurrency: MyCurrency = MyCurrency()
let currencySymbol = NSLocale.current.currencyCode!

// my date is either a string: yyyy-mm-dd, or a time-interval-since-1970
// this subclass enforces those conversion formats / rules
// it is instantiated in the tabBar view controller
class MyDate: DateFormatter {
    let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone (abbreviation:"EST5EDT")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: date conversion helpers toString and fromString
    override func string (from: Date) -> String {
        return dateFormatter.string(from: from)
    }
    override func date (from: String) -> Date {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: from)!
    }
    
    func timeInterval(from: String) -> TimeInterval {
        return self.date(from: from).timeIntervalSince1970
        
    }
    func string(fromInterval: TimeInterval) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: fromInterval))
    }
}

// optional Int class, provides validations for optional conversions
// and string conversion where the input might not be an integer
// never is instantiated. just used for conversions
class OptInt: NSObject {
    
    // first version returns empty string if the value is nil or is NOT an integer (e.g. 12.34 => "")
    class func string (from: NSNumber?) -> String {
        if from != nil {
            let result = from! as? Int
            if result != nil {
                return "\(result!)"
            }
        }
        return ""
    }
    
    // second version returns empty stting if the value is nil, or the truncated value as an integer (e.g. 12.34 => 12)
    class func string0 (from: NSNumber?) -> String
    {
        if from != nil {
            let result = from!.intValue
            return "\(result)"
        }
        return ""
    }

    // converting string to int returns error (nil) if there is a '.' in the number string
    class func int (from: String) -> Int? {
        if from.range(of: ".") == nil {
            let formatter = NumberFormatter()
            formatter.generatesDecimalNumbers = true
            if let tmp = formatter.number(from: from) as! NSInteger? {
                return tmp
            }
        }
        return nil
    }

    class func int (from: NSDecimalNumber) -> Int {
        return from.intValue
    }
}

class MyCurrency : NSObject {
    let currFormatter = NumberFormatter()
    override init () {
        currFormatter.numberStyle = NumberFormatter.Style.currency
    }

    func string (fromDec: NSDecimalNumber) -> String {
        return currFormatter.string(from: fromDec)!
    }

    func string (fromDbl: Double) -> String {
        return String(format: "%f",  fromDbl)
    }

}
