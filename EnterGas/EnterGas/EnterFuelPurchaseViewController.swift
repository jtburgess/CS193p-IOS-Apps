//
//  EnterFuelPurchaseViewController.swift
//  EnterGas
//
//  Created by John Burgess on 10/27/17.
//  Copyright © 2017 JTBURGESS. All rights reserved.

// nextField logic from https://stackoverflow.com/questions/9540500/ios-app-next-key-wont-go-to-the-next-text-field
// ACEAutocompleteBar from https://stackoverflow.com/questions/31167416/customizing-quicktype-suggestions-in-ios/35511249#35511249

import UIKit
import CoreData
//import ACEAutocompleteBar

class EnterFuelPurchaseViewController: UIViewController, UITextFieldDelegate { // , ACEAutocompleteDataSource, ACEAutocompleteDelegate
    
    let currencySymbol = NSLocale.current.currencyCode!

    // MARK - data
    @IBOutlet weak var brand: UITextField!
    @IBOutlet weak var odometer: UITextField!
    @IBOutlet weak var toEmpty: UITextField!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var cost: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var note: UITextField!
    @IBOutlet weak var Errors: UILabel!
    @IBOutlet weak var vehicleName: UITextField!
    @IBOutlet weak var fuelType: UITextField!
    
    // MARK: user interface
    override func viewDidLoad() {
        super.viewDidLoad()
        resetFields()
        assignNextActions()
        costLabel.text = "Cost (\(currencySymbol))"
        
       /*
        self.brand.setAutocompleteWith(self, delegate: self, customize: { inputView in
             // customize the view (optional)
             //inputView.font = UIFont.systemFontOfSize(20)
             //inputView.textColor = UIColor.whiteColor()
             //inputView.backgroundColor = UIColor.blueColor()
            inputView?.isHidden = false
        })
        */

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
        fuelType.text = fuelTypePickerValues [currentFuelTypeID]
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
        if let moveTo = nextField[textField] {
            print("Return entered in \(textField.description) goes to \(moveTo.description)")
            moveTo.becomeFirstResponder()
        } else {
            print("Return entered in \(textField.description) no next defined")
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: (notused) ACEAutocompleteBar delegate
    /*
    func minimumCharacters(toTrigger inputView: ACEAutocompleteInputView!) -> UInt {
        return 1
    }
    func inputView(_ inputView: ACEAutocompleteInputView!, itemsFor query: String!, result resultBlock: (([Any]?) -> Void)!) {        
        inputView.isHidden = false
        inputView.alpha = 0.75
        print("inputView called")
        if resultBlock != nil {
            print("inputView nonNil")
            DispatchQueue.global(qos:DispatchQoS.QoSClass.default).async() {
                var data:NSMutableArray = []
                
                if(self.brand.isFirstResponder){
                    let myContext: NSManagedObjectContext = self.container.viewContext
                    data = Brand.RequestAll(context: myContext) as! NSMutableArray
                    print("got Brand list \(data.count)")
                }
                DispatchQueue.main.async() { resultBlock(data as [AnyObject]) }
            }
        }
    }
    func textField(_ textField: UITextField!, didSelect object: Any!, in inputView: ACEAutocompleteInputView!) {
        textField.text = String(describing: object)
    }
    */
    
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
    
    @IBAction func FuelTypePickerPopup(_ sender: Any) {
        FuelTypePickerDialog().show(fuelTypeID: currentFuelTypeID) {
            (returnValue) -> Void in
            if let theFuelTypeID = returnValue {
                self.fuelType.text = fuelTypePickerValues [theFuelTypeID]
                currentFuelTypeID = theFuelTypeID
                defaults.setValue(theFuelTypeID, forKey: fuelTypeKey)
            }
        }
    }

    // MARK: SAVE button saves the data to CoreData
    @IBAction func saveThisEntry(_ sender: UIButton) {
        // add validations here so I can eliminate the '!' in the gasEntry() call
        print("Enter SaveThisEntry")
        Errors.text = GasEntry.save(brand: brand.text, odometer: odometer.text, toEmpty: toEmpty.text,
                           cost: cost.text, amount: amount.text, vehicleName: vehicleName.text,
                           note: note.text, fuelType: fuelType.text, date: date.text)
        
        // force the keyboard to go away so we can see the error messages
        view.endEditing(true)
        if Errors.text == "" {
            resetFields()
            Errors.text = "Purchase saved."
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("did receive Memory Warning")
    }
    
    /*
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print ("segue to Entry screen. NOt used with tab view controller")
    }
    */
}
