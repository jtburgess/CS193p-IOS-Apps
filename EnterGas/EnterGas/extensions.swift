//
//  extensions.swift
//  EnterGas
//
//  Created by John Burgess on 2/25/18.
//  Copyright © 2018 JTBURGESS. All rights reserved.
//

import UIKit

// my date is either a string: yyyy-mm-dd, or a time-interval-since-1970
// this subclass enforces those rules
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

