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

class EnterFuelPurchaseViewController: UIViewController, UITextFieldDelegate, ACEAutocompleteDataSource, ACEAutocompleteDelegate {
    
    let currencySymbol = NSLocale.current.currencyCode!

    // MARK - data
    @IBOutlet weak var brand: UITextField!
    @IBOutlet weak var odometer: UITextField!
    @IBOutlet weak var toEmpty: UITextField!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var cost: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var note: UITextField!
    @IBOutlet weak var Errors: UILabel!

    let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer

    // MARK - user interface
    override func viewDidLoad() {
        super.viewDidLoad()
        resetFields()
        assignNextActions()
        costLabel.text = "Cost \(currencySymbol))"
        
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
        print("fields reset")
    }

    // MARK - UITextFieldDelegate
    private var nextField: [ UITextField : UITextField ] = [:]
    func assignNextActions() {
        brand.delegate = self
        odometer.delegate = self
        cost.delegate = self
        amount.delegate = self
        toEmpty.delegate = self
        note.delegate = self
        
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
    
    // MARK - ACEAutocompleteBar delegate
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

    // MARK: SAVE button saves the data to CoreData
    @IBAction func saveThisEntry(_ sender: UIButton) {
        // add validations here so I can eliminate the '!' in the gasEntry() call
        print("Enter SaveThisEntry")
        var errors = false
        Errors.text = ""
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true

        // brand list validataions
        let theBrand = brand.text ?? ""
        if theBrand == "" {
            errors = true
            Errors.text?.append ("Please fill in the Brand purchased\n")
        }

        var theOdo : Double = -1
        if let tmp = formatter.number(from: odometer.text!) as! Double? {
            theOdo = tmp
        } else {
            errors = true
            Errors.text?.append("Bad Odometer value\n")
        }

        var milesLeft : NSDecimalNumber = 0
        if let tmp = formatter.number(from: toEmpty.text!) as! NSDecimalNumber? {
            milesLeft = tmp
        } else {
            // missing milesLeft is not an error
            //errors = true
            //Errors.text?.append("Bad Odometer value\n")
        }

        var theCost: NSDecimalNumber = -1
        if let tmp = formatter.number(from: cost.text!) as! NSDecimalNumber? {
            theCost = tmp
        } else {
            errors = true
            Errors.text?.append("Bad Cost value\n")
        }

        var theAmount: NSDecimalNumber = -1
        if let tmp = formatter.number(from: amount.text!) as! NSDecimalNumber? {
            theAmount = tmp
        } else {
            errors = true
            Errors.text?.append("Bad Amount value\n")
        }

        print ("Save this Entry: brand=\(theBrand), odo=\(theOdo), cost=\(theCost), gals=\(theAmount)")

        if errors {
            print ("There are errors")
            return
        }
        
        var theDate : TimeInterval
        theDate = date.date.timeIntervalSince1970
        let myContext: NSManagedObjectContext = container.viewContext

        if let gasEntry = NSEntityDescription.insertNewObject(forEntityName: "GasEntry", into: myContext) as? GasEntry {
            print("create gasentry Entity")
            let brandEntry = Brand.FindOrAdd(theBrand:theBrand, context:gasEntry.managedObjectContext!)
            gasEntry.brand = brandEntry
            
            print("created Brand Entity link")
            gasEntry.date = theDate
            gasEntry.odometer = NSDecimalNumber(value:theOdo)
            gasEntry.toEmpty = milesLeft
            gasEntry.cost = theCost
            gasEntry.amount = theAmount
            gasEntry.note = note.text ?? ""
            
            // calculate dist from last fillup; needed to calc MPG
            if let prevGasEntry = GasEntry.getPrevious(context: myContext, theDate: theDate) {
                let prevOdo = prevGasEntry.odometer! as Double
                gasEntry.distance = NSDecimalNumber(value:(theOdo - prevOdo))
            } else {
                gasEntry.distance = (theOdo as! NSDecimalNumber)
            }
            do {
                try myContext.save()
            } catch let error {
                print("Core Data Save Error: \(error)")
            }
            resetFields()
            print("gasentry Entity saved")
            Errors.text? = "Purchase saved."
            
        } else {
            print ("gasEntry not set")
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

