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

class FuelTypePickerView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.dataSource = self
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        print("FuelPicker numberOfComponents() called")
        return 1
    }
    
    override func numberOfRows(inComponent component: Int) -> Int {
        print("FuelPickerView numberOfRows ( InComponent \(component) = \(fuelTypePickerValues.count) called")
        return fuelTypePickerValues.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        print("FuelPickerView ( numberOfRowsInComponent \(component) = \(fuelTypePickerValues.count) called")
        return fuelTypePickerValues.count
    }
 
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        print("FuelPickerView(... titleForRow \(row) called")
        return fuelTypePickerValues[row]
    }

    func pickerView(_ pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int){
        // EnterFuelPurchaseViewController.fuelType.text = fuelTypePickerValues[row]
        // self.view.endEditing(true)
        print ("FuelPickerView(... didSelectRow \(row) called")
    }
}
