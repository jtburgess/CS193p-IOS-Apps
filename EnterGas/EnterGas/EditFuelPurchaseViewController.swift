//
//  EditFuelPurchaseViewController.swift
//  EnterGas
//
//  Created by John Burgess on 2/28/18.
//  Copyright © 2018 JTBURGESS. All rights reserved.
//

import UIKit
import CoreData

class EditFuelPurchaseViewController: UIViewController, UITextFieldDelegate {
    // MARK - data
    @IBOutlet weak var brand: UITextField!
    @IBOutlet weak var odometer: UITextField!
    @IBOutlet weak var toEmpty: UITextField!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var cost: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var note: UITextField!
    @IBOutlet weak var date: UITextField!
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

    // the cell being edited - set by segue
    var myData: GasEntry? // { didSet { resetFields() } }

    // MARK: user interface
    override func viewDidLoad() {
        print("Edit view did load")
        super.viewDidLoad()
        resetFields()
        assignNextActions()
        costLabel.text = "Cost (\(currencySymbol))"
    }

    private func resetFields() {
        // set field values from the record that caused the segue
        brand.text  = myData?.brand?.brandName ?? "unknown"
        // here we want the actual numbers, not the formatted values, so they can be edited
        odometer.text = "\(myData!.odometer ?? 0.0)"
        toEmpty.text = "\(myData!.toEmpty ?? 0.0)"
        cost.text    = "\(myData?.cost ?? 0.0)"
        amount.text = String(format:"%.2f", ((myData?.amount)! as Double) )
        date.text  = myDate.string(fromInterval: (myData?.date)!)
        note.text = myData?.note
        vehicleName.text = myData?.vehicle?.vehicleName
        myFuelTypeID = myData?.fuelTypeID as! Int
        let tmpStr = fuelTypePickerValues[ myFuelTypeID ]
        // retain only the first char as string
        fuelType.text = tmpStr[tmpStr.startIndex...tmpStr.startIndex]

        // handle older records by assuming true for the new Bools
        if myData?.cash_credit == nil || myData?.cash_credit as! Bool {
            cash_credit.setTitle("Credit", for: .normal)
        } else {
            cash_credit.setTitle("Cash", for: .normal)
        }
        if myData?.partial_fill == nil || myData?.partial_fill as! Bool {
            partial_fill.setTitle("FillUp", for: .normal)
        } else {
            partial_fill.setTitle("Partial", for: .normal)
        }
        print("Edit fields initialized")
        
        Errors.text = ""
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
        if let moveTo = nextField[textField] {
            print("Return entered in \(textField.description) goes to \(moveTo.description)")
            moveTo.becomeFirstResponder()
        } else {
            print("Return entered in \(textField.description) no next defined")
            textField.resignFirstResponder()
        }
        return true
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
    @IBAction func VehiclePickerPopup(_ sender: UIButton) {
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

    @IBAction func FuelTypePickerPopup (_ sender: UIButton) {
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
    
    // MARK: SAVE/Delete/Cancel buttons
    @IBAction func deleteThisEntry(_ sender: UIButton) {
        print("DELETE Edit Entry")
        myData?.delete()
        Errors.text = "Entry Deleted. (Go Back)"
    }

    @IBAction func saveThisEntry(_ sender: UIButton) {
        // add validations here so I can eliminate the '!' in the gasEntry() call
        print("Save Edit Entry")
        let cashCreditBool  = (cash_credit.currentTitle == "Credit")
        let partialFillBool = (partial_fill.currentTitle == "FillUp")
        Errors.text = myData!.update( brand: brand.text, odometer: odometer.text, toEmpty: toEmpty.text,
                                    cost: cost.text, amount: amount.text, vehicleName: vehicleName.text,
                                    note: note.text, fuelTypeID: myFuelTypeID, date: date.text,
                                    cash_credit: cashCreditBool, partial_fill: partialFillBool,
                                    validate: true)
        
        // force the keyboard to go away so we can see the error messages
        view.endEditing(true)
        if Errors.text == "" {
            resetFields()
            Errors.text = "Edits Saved."
        } else {
            // if there are errors, enable the second-chance OK button
            extraOKbutton.isHidden = false
        }
    }
    
    @IBAction func saveWithoutValidation(_ sender: Any) {
    // called from the normally hidden OK button
        print("Enter Save UNVALIDATED Entry")
        let cashCreditBool  = (cash_credit.currentTitle == "Credit")
        let partialFillBool = (partial_fill.currentTitle == "FillUp")
        var errorMessage = myData!.update(brand: brand.text, odometer: odometer.text, toEmpty: toEmpty.text,
                                         cost: cost.text, amount: amount.text, vehicleName: vehicleName.text,
                                         note: note.text, fuelTypeID: myFuelTypeID, date: date.text,
                                         cash_credit: cashCreditBool, partial_fill: partialFillBool,
                                         validate: false)
        
        // force the keyboard to go away so we can see the error messages
        view.endEditing(true)
        if errorMessage == "" {
            resetFields()
            Errors.text = "Edits saved."
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
