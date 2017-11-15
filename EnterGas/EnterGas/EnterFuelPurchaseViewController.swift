//
//  EnterFuelPurchaseViewController.swift
//  EnterGas
//
//  Created by John Burgess on 10/27/17.
//  Copyright © 2017 JTBURGESS. All rights reserved.
//

import UIKit
import CoreData

class EnterFuelPurchaseViewController: UIViewController {

    // MARK - data
    @IBOutlet weak var brand: UITextField!
    @IBOutlet weak var odometer: UITextField!
    @IBOutlet weak var cost: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var date: UIDatePicker!
    
    // set by segue to GasListTableViewController.gasList[0]
    var gasListSection : Int = 0

    // MARK - user interface
    override func viewDidLoad() {
        super.viewDidLoad()
        resetFields()
    }

    private func resetFields() {
        // reset fields to empty
        brand.text = ""
        odometer.text = ""
        cost.text = ""
        amount.text = ""
        Errors.text = ""
        
    }

    @IBOutlet weak var Errors: UILabel!
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

        var theOdo : NSDecimalNumber = -1
        if let tmp = formatter.number(from: odometer.text!) as! NSDecimalNumber? {
            theOdo = tmp
        } else {
            errors = true
            Errors.text?.append("Bad Odometer value\n")
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

        print ("Save this Entry: brand=\(theBrand), odo=\(theOdo), cost=\(theCost)")

        if errors {
            print ("There are errors")
            return
        }
        
        var theDate : TimeInterval
        theDate = date.date.timeIntervalSince1970

        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let myContext: NSManagedObjectContext = container.viewContext
        
        if let gasEntry = NSEntityDescription.insertNewObject(forEntityName: "GasEntry", into: myContext) as? GasEntry {
            print("create gasentry Entity")
            let brandEntry = Brand.Request(theBrand:theBrand, context:gasEntry.managedObjectContext!)
            gasEntry.brand = brandEntry
            
            print("created Brand Entity link")
            gasEntry.date = theDate
            gasEntry.odometer = theOdo
            gasEntry.cost = theCost
            gasEntry.amount = theAmount
 
            do {
                try myContext.save()
            } catch let error {
                print("Core Data Save Error: \(error)")
            }
            resetFields()
            print("gasentry Entity saved")
        } else {
            print ("gasEntry not set")
        }

        resetFields()
        Errors.text? = "Purchase saved."
        // segue back?
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
