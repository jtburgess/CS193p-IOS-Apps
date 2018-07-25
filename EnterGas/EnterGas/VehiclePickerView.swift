//
//  VehiclePickerView
//  EnterGas
//
//  Created by John Burgess on 1/11/18.
//  Copyright © 2018 JTBURGESS. All rights reserved.
//

import UIKit

// treat this like an enum, and store the index, elsewhere
var VehiclePickerValues: [String] = []

class VehiclePickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    override init(frame: CGRect) {
        print ("VehiclePickerView init")
        super.init(frame: frame)
        self.delegate = self
        self.dataSource = self
        VehiclePickerValues = Vehicle.RequestAll() as! [String]
        print ("Vehicle Picker view initialized with: \(VehiclePickerValues)")
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: PickerViewDelegate
    @nonobjc func pickerView(_: UIPickerView, rowHeightForComponent: Int) {
        print ("VehiclePicker rowHeight=\(rowHeightForComponent)")
    }
    @nonobjc func pickerView(_: UIPickerView, widthForComponent: Int){
        print ("VehiclePicker widthForComponent=\(widthForComponent)")
        
    }
    
    // MARK: PickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return VehiclePickerValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return VehiclePickerValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        print ("VehiclePickerView(... didSelectRow \(row) called")
    }
    
}

