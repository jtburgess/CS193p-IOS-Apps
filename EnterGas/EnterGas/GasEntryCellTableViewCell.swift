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
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var brand: UILabel!
    @IBOutlet weak var odometer: UILabel!
    @IBOutlet weak var toEmpty: UILabel!
    @IBOutlet weak var cost: UILabel!
    @IBOutlet weak var costPerUnit: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var mpg: UILabel!
    
    var myData: GasEntry? {didSet { updateUI() }}
    
    fileprivate func updateUI()
    {
        // update the display fields in the UI
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone (abbreviation:"EST5EDT")
        let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: (myData?.date)!))
        date.text  = dateString
        // print ("date = \(dateString)")
        brand.text  = myData?.brand?.brandName ?? "unknown"
        odometer.text = "\(myData?.odometer ?? 0)"
        toEmpty.text = "\(myData?.toEmpty ?? 0)"

        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        cost.text    = formatter.string(from:(myData?.cost)!)
        amount.text = "\(myData?.amount ?? 0.0)"

        if let costD  = myData?.cost as Double?,
           let amountD = myData?.amount as Double? {
            if (costD > 0.0) && (amountD > 0.0) {
                mpg.text = String(format:"%.01f", (costD / amountD))
            }
        }
    }

}
