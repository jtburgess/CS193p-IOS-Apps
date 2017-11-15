//
//  GasEntryCellTableViewCell.swift
//  EnterGas
//
//  Created by John Burgess on 10/26/17.
//  Copyright © 2017 JTBURGESS. All rights reserved.
//

import UIKit

class GasEntryCellTableViewCell: UITableViewCell {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var brand: UILabel!
    @IBOutlet weak var odometer: UILabel!
    @IBOutlet weak var cost: UILabel!
    @IBOutlet weak var gallons: UILabel!
    
    var myData: GasEntry? {didSet { updateUI() }}
    
    fileprivate func updateUI()
    {
        // update the display fields in the UI
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone (abbreviation:"EST5EDT")
        let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: (myData?.date)!))
        date.text  = dateString
        print ("date 2017-01-01 = \(dateString)")
        brand.text  = myData?.brand?.brandName ?? "unknown"
        odometer.text = "\(myData?.odometer ?? 0)"
        cost.text    = "\(myData?.cost ?? 0)"
        gallons.text = "\(myData?.amount ?? 0.0)"
    }

    func updateHeader()
    {
        // update the display fields in the UI
        
        date.text = "Date    "
        brand.text = "Brand"
        odometer.text = "Miles"
        cost.text = "Cost"
        gallons.text = "Amount"
    }

}
