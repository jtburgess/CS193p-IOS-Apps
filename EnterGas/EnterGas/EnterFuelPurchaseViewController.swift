//
//  EnterFuelPurchaseViewController.swift
//  EnterGas
//
//  Created by John Burgess on 10/27/17.
//  Copyright © 2017 JTBURGESS. All rights reserved.

// nextField logic from https://stackoverflow.com/questions/9540500/ios-app-next-key-wont-go-to-the-next-text-field

import UIKit
import CoreData
//import ACEAutocompleteBar

class EnterFuelPurchaseViewController: UIViewController, UITextFieldDelegate {

    // MARK - data
    @IBOutlet weak var brand: UITextField!
    @IBOutlet weak var odometer: UITextField!
    @IBOutlet weak var toEmpty: UITextField!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var cost: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var note: UITextField!
    @IBOutlet weak var vehicleName: UITextField!
    @IBOutlet weak var fuelType: UILabel!
    @IBOutlet weak var Errors: UILabel!
    
    // toggle buttons for Cash/Credit
    @IBOutlet weak var cash_credit: UIButton!
    @IBAction func CashOrCredit(_ sender: Any) {
        if cash_credit.currentTitle == "Credit" {
            cash_credit.setTitle("Cash", for: .normal)
        } else {
            cash_credit.setTitle("Credit", for: .normal)
        }
    }
    
    // ... and fill-up or partial
    @IBOutlet weak var partial_fill: UIButton!
    @IBAction func FillOrPartial(_ sender: Any) {
        if partial_fill.currentTitle == "FillUp" {
            partial_fill.setTitle("Partial", for: .normal)
        } else {
            partial_fill.setTitle("FillUp", for: .normal)
        }
    }

    @IBOutlet weak var extraOKbutton: UIButton!
    
    var myFuelTypeID: Int = 0
    
    // MARK: user interface
    override func viewDidLoad() {
        super.viewDidLoad()
        extraOKbutton.isHidden = true
        getDefaults()
        resetFields()
        assignNextActions()
        costLabel.text = "Cost (\(currencySymbol))"
    }

    private func resetFields() {
        // reset fields to empty
        brand.text = ""
        odometer.text = ""
        toEmpty.text = ""
        cost.text = ""
        note.text = ""
        amount.text = ""
        Errors.text = ""
        myFuelTypeID = theVehicle.get(key: fuelTypeKey) as! Int
        fuelType.text = fuelTypePickerValues [myFuelTypeID]
        if date.text == "" || date.text == "theDate" {
            self.date.text = myDate.string(from: Date.init())
        }
        vehicleName.text = currentVehicle
        print("fields reset")
    }

    // MARK: UITextFieldDelegate
    private var nextField: [ UITextField : UITextField ] = [:]
    func assignNextActions() {
        brand.delegate = self
        odometer.delegate = self
        cost.delegate = self
        amount.delegate = self
        toEmpty.delegate = self
        note.delegate = self
        
        // start off the cursor in the brand field
        brand.becomeFirstResponder()
        
        nextField[brand] = odometer
        nextField[odometer] = cost
        nextField[cost] = amount
        nextField[amount] = toEmpty
        nextField[toEmpty] = note
        print("next field actions assigned")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if textField == cost || textField == amount {
            // auto add decimal point if appropriate
            textField.text = addOptionalDecimalPoint(value: textField.text!)
        }
        if let moveTo = nextField[textField] {
            print("Return entered in \(textField.description) goes to \(moveTo.description)")
            moveTo.becomeFirstResponder()
        } else {
            print("Return entered in \(textField.description) no next defined")
            textField.resignFirstResponder()
        }
        return true
    }

    // add a decimal point if there is none, and the string is 3 digits or more (e.g., make 999 => 9.99
    private func addOptionalDecimalPoint (value: String) -> String {
        if value.range(of: ".") == nil && value.count >= 3 {
            var mutatedValue = value
            mutatedValue.insert(".", at: value.index(value.endIndex, offsetBy: -2))
            return mutatedValue
        } else {
            return value
        }
    }
    // MARK: date picker and fuel type popups
    @IBAction func datePickerPopup(_ sender: Any) {
        let theDate = myDate.date(from: date.text!)
        DatePickerDialog().show("Date Picker",
                                doneButtonTitle: "Done",
                                cancelButtonTitle: "Cancel",
                                defaultDate: theDate,
                                datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                self.date.text = myDate.string(from: dt)
            }
        }
    }
    
    @IBAction func brandPickerPopup(_ sender: UIButton) {
        GenericPickerDialog(
            pickerView: BrandPickerView(frame: CGRect(x: 0, y: 30, width: 300, height: 216))
            ).show(
                startValue: brand.text!,
                title: "Brandname Picker"
            ) {
                (returnValue) -> Void in
                if let i = returnValue {
                    self.brand.text = BrandPickerValues[i]
                }
        }
    }
    @IBAction func vehiclePickerPopup(_ sender: UIButton) {
        GenericPickerDialog(
            pickerView: VehiclePickerView(frame: CGRect(x: 0, y: 30, width: 300, height: 216))
            ).show(
                startValue: currentVehicle,
                title: "Vehicle Name Picker"
            ) {
                (returnValue) -> Void in
                if let i = returnValue {
                    let theVehicleName = VehiclePickerValues[i]
                    self.vehicleName.text = theVehicleName
                    currentVehicle = theVehicleName
                    defaults.setValue(theVehicleName, forKey: vehicleNameKey)
                }
        }
    }

    @IBAction func FuelTypePickerPopup(_ sender: Any) {
        GenericPickerDialog(
            pickerView: FuelTypePickerView(frame: CGRect(x: 0, y: 30, width: 300, height: 216))
            ).show(
                startValue: fuelTypePickerValues [myFuelTypeID],
                title: "Fuel Type Picker"
            ) {
            (returnValue) -> Void in
            if let theFuelTypeID = returnValue {
                // this does not update the default fuel type
                self.myFuelTypeID = theFuelTypeID
                self.fuelType.text = fuelTypePickerValues [theFuelTypeID]
            }
        }
    }

    // MARK: SAVE button saves the data to CoreData
    @IBAction func saveThisEntry(_ sender: UIButton) {
        print("Enter SaveThisEntry")
        let cashCreditBool  = (cash_credit.currentTitle == "Credit")
        let partialFillBool = (partial_fill.currentTitle == "FillUp")
        Errors.text = GasEntry.save(brand: brand.text, odometer: odometer.text, toEmpty: toEmpty.text,
                           cost: cost.text, amount: amount.text, vehicleName: vehicleName.text,
                           note: note.text, fuelTypeID: myFuelTypeID, date: date.text,
                           cash_credit: cashCreditBool, partial_fill: partialFillBool,
                           validate: true)
        
        // force the keyboard to go away so we can see the error messages
        view.endEditing(true)
        if Errors.text == "" {
            resetFields()
            Errors.text = "Purchase saved."
        } else {
            // if there are errors, enable the second-chance OK button
            extraOKbutton.isHidden = false
        }
    }

    // called from the normally hidden OK button
    @IBAction func SaveWithoutValidation(_ sender: Any) {
        print("Enter Save UNVALIDATED Entry")
        let cashCreditBool  = (cash_credit.currentTitle == "Credit")
        let partialFillBool = (partial_fill.currentTitle == "FillUp")
        var errorMessage = GasEntry.save(brand: brand.text, odometer: odometer.text, toEmpty: toEmpty.text,
                                    cost: cost.text, amount: amount.text, vehicleName: vehicleName.text,
                                    note: note.text, fuelTypeID: myFuelTypeID, date: date.text,
                                    cash_credit: cashCreditBool, partial_fill: partialFillBool,
                                    validate: false)
        
        // force the keyboard to go away so we can see the error messages
        view.endEditing(true)
        if errorMessage == "" {
            resetFields()
            Errors.text = "Purchase saved."
        } else {
            errorMessage.append("Entry saved despite errors.")
            Errors.text = errorMessage
        }
        extraOKbutton.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("did receive Memory Warning")
    }
}
