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
    
    // constant formatters
    let dateFormatter = DateFormatter()
    let currFormatter = NumberFormatter()

    fileprivate func updateUI()
    {
        // where can I do these ONCE?
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone (abbreviation:"EST5EDT")
        currFormatter.numberStyle = NumberFormatter.Style.currency

        // update the display fields in the UI
        date.text  = dateFormatter.string(from: Date(timeIntervalSince1970: (myData?.date)!))
        note.text = myData?.note
        brand.text  = myData?.brand?.brandName ?? "unknown"
        odometer.text = "\(myData?.odometer ?? 0)"
        toEmpty.text = "\(myData?.toEmpty ?? 0)"
        cost.text    = currFormatter.string(from:(myData?.cost)!)
        amount.text = String(format:"%.1f", ((myData?.amount)! as Double) )

        if let costD  = myData?.cost as Double?,
        let amountD = myData?.amount as Double? {
            if (costD > 0.0) && (amountD > 0.0) {
                costPerUnit.text = currFormatter.string(from: ((costD / amountD) as NSNumber) )
                //costPerUnit.text = String(format:"%.03f", (costD / amountD))
            } else {
                costPerUnit.text = ""
            }
        }
        // mpg needs miles since last fill-up; fetched save() in the Entry View
        if let distD = myData?.distance as Double?,
           let amountD = myData?.amount as Double? {
            let toEmptyD = myData?.toEmpty as Double? ?? 0.0
            if (distD > 0.0) && (amountD > 0.0) {
                mpg.text = String(format:"%.1f", ((distD-toEmptyD) / amountD))
            } else {
                mpg.text = ""
            }
        }
    }

}
