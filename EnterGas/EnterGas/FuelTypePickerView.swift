//
//  FuelTypePickerView
//  EnterGas
//
//  Created by John Burgess on 1/11/18.
//  Copyright © 2018 JTBURGESS. All rights reserved.
//

import UIKit

// treat this like an enum, and store the index, elsewhere
let fuelTypePickerValues = [ 0:"Regular", 1:"MidGrade", 2:"Premium", 3:"Diesel" ]

class FuelTypePickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {

    override init(frame: CGRect) {
        print ("FuelTypePickerView init")
        super.init(frame: frame)
        self.delegate = self
        self.dataSource = self
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: PickerViewDelegate
    @nonobjc func pickerView(_: UIPickerView, rowHeightForComponent: Int) {
        print ("FuelTypePicker rowHeight=\(rowHeightForComponent)")
    }
    @nonobjc func pickerView(_: UIPickerView, widthForComponent: Int){
        print ("FuelTypePicker widthForComponent=\(widthForComponent)")

    }

    // MARK: PickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        print("FuelPickerDS (number of components == 1)")
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // print("FuelPickerDS (numberOfRowsInComponent \(component) = \(fuelTypePickerValues.count) called")
        return fuelTypePickerValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // print("FuelPickerView(... titleForRow \(row) = \(fuelTypePickerValues[row]!)")
        return fuelTypePickerValues[row]!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        // EnterFuelPurchaseViewController.fuelType.text = fuelTypePickerValues[row]
        // self.view.endEditing(true)
        print ("FuelPickerView(... didSelectRow \(row) called")
    }
    
}
