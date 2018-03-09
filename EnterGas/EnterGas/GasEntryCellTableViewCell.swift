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
    @IBOutlet weak var fuelType: UILabel!
    
    var myData: GasEntry? {didSet { updateUI() }}

    fileprivate func updateUI()
    {
        // update the display fields in the UI
        brand.text  = myData?.brand?.brandName ?? "unknown"
        odometer.text = OptInt.string (from: myData?.odometer)
        toEmpty.text = OptInt.string (from: myData?.toEmpty)
        cost.text    = myCurrency.string(fromDec:(myData?.cost)!)
        amount.text = String(format:"%.1f", ((myData?.amount)! as Double) )
        date.text  = myDate.string(fromInterval: (myData?.date)!)
        note.text = myData?.note

        let tmpStr = fuelTypePickerValues[ (myData?.fuelTypeID as? Int)! ]!
        // retain only the first char as string
        fuelType.text = tmpStr[tmpStr.startIndex...tmpStr.startIndex]
        
        if let costD  = myData?.cost as Double?,
        let amountD = myData?.amount as Double? {
            if (costD > 0.0) && (amountD > 0.0) {
                costPerUnit.text = myCurrency.string(fromDbl: (costD / amountD) )
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
