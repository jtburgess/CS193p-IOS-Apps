//
//  GasTitleCellTableViewCell.swift
//  EnterGas
//
//  Created by John Burgess on 11/16/17.
//  Copyright © 2017 JTBURGESS. All rights reserved.
//

import UIKit
import Foundation

// future TBD -- enable click on title labels to sort
struct SortField {
    var fieldName: String
    var sortUp: Bool
    var button: UIButton?
}
class GasTitleCellTableViewCell: UITableViewCell {
    @IBOutlet weak var brand: UILabel!
    //@IBOutlet weak var dateButton: UIButton!
    
    var sortField: SortField = SortField (
        fieldName: "Date",
        sortUp: false,
        button: nil
    )
    //let normAttr: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14)]
    //let boldAttr: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14)]

    override func didAddSubview(_ subview: UIView) {
        print("didAddSubView Gas TITLE CellView")
        super.didAddSubview(subview)
        /*
        sortField = SortField (
            fieldName: "Date",
            sortUp: false,
            button: dateButton
        )
        */
    }

    @IBAction func sortAction(_ sender: UIButton) {
        let fieldName = sender.currentAttributedTitle!
        if sortField.fieldName == fieldName.string {
            // same field, just switch sort order
            sortField.sortUp = !sortField.sortUp
            print("switch \(fieldName.string) sort order to: \(sortField.sortUp)")
        } else {
            // change previous field label back to normal and make this field BOLD
            print("switch sort field from \(sortField.fieldName) to \(fieldName.string)")
            //sortField.button?.setAttributedTitle(NSAttributedString(string: sortField.fieldName, attributes:normAttr), for: .normal)
            //sender.setAttributedTitle(NSAttributedString(string: sortField.fieldName, attributes:boldAttr), for: .normal)
            sortField.button = sender
            sortField.fieldName = fieldName.string
        }
    }
    func updateHeader() {
        // update the display fields in the UI
        print("update Header / Title row")
        //date.text = "Date    "
        brand.text = currentVehicle
        //odometer.text = "Odometer"
        //cost.text = "Cost"
        //gallons.text = "Amt"
    }

}
