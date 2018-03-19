//
//  BrandPickerView
//  EnterGas
//
//  Created by John Burgess on 1/11/18.
//  Copyright © 2018 JTBURGESS. All rights reserved.
//

import UIKit

// treat this like an enum, and store the index, elsewhere
var BrandPickerValues: [String] = []

class BrandPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    override init(frame: CGRect) {
        print ("BrandPickerView init")
        super.init(frame: frame)
        self.delegate = self
        self.dataSource = self
        BrandPickerValues = Brand.RequestAll() as! [String]
        print ("Brand Picker view initialized with: \(BrandPickerValues)")
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: PickerViewDelegate
    @nonobjc func pickerView(_: UIPickerView, rowHeightForComponent: Int) {
        print ("BrandPicker rowHeight=\(rowHeightForComponent)")
    }
    @nonobjc func pickerView(_: UIPickerView, widthForComponent: Int){
        print ("BrandPicker widthForComponent=\(widthForComponent)")
        
    }
    
    // MARK: PickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return BrandPickerValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return BrandPickerValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        print ("BrandPickerView(... didSelectRow \(row) called")
    }
    
}

