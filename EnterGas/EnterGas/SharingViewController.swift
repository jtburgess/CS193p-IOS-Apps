//
//  SharingViewController.swift
//  EnterGas
//
//  Created by John Burgess on 1/1/18.
//  Copyright © 2018 JTBURGESS. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class SharingViewController: UIViewController {

    let PerUnit = true // eventually make this a checkBox
    // MARK: popups
    @IBAction func SelectVehiclePopup(_ sender: Any) {
        print ("set default vehicle popup")
        GenericPickerDialog(
            pickerView: VehiclePickerView(frame: CGRect(x: 0, y: 30, width: 300, height: 216))
            ).show(
                startValue: currentVehicle,
                title: "Vehicle Name Picker"
            ) {
                (returnValue) -> Void in
                if let i = returnValue {
                    let theVehicleName = VehiclePickerValues[i]
                    self.defVehicle.text = theVehicleName
                    currentVehicle = theVehicleName
                    defaults.setValue(theVehicleName, forKey: vehicleNameKey)
                    let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
                    let context: NSManagedObjectContext = container.viewContext
                    _ = Vehicle.FindOrAdd(theVehicleName: theVehicleName, context: context)
                }
        }
    }
    
    @IBAction func FuelTypePickerPopup(_ sender: Any) {
        print ("set default fuel type popup")
        GenericPickerDialog(
            pickerView: FuelTypePickerView(frame: CGRect(x: 0, y: 30, width: 300, height: 216))
            ).show(
                startValue: fuelTypePickerValues [theVehicle.get(key: fuelTypeKey) as! Int],
                title: "Default Fuel Type Picker"
            ) {
                (returnValue) -> Void in
                if let theFuelTypeID = returnValue {
                    self.defFuel.text = fuelTypePickerValues [theFuelTypeID]
                    theVehicle.set(key: fuelTypeKey, value: theFuelTypeID as NSNumber)
                }
        }
    }
    

    // MARK: on screen fields and actions
    @IBOutlet weak var defVehicle: UITextField!
    @IBOutlet weak var defFuel: UILabel!

    // toggle buttons for Cash/Credit
    @IBOutlet weak var cash_credit: UIButton!
    @IBAction func CashOrCredit(_ sender: Any) {
        if cash_credit.currentTitle == "Credit" {
            cash_credit.setTitle("Cash", for: .normal)
            theVehicle.set(key: cashCreditKey, value: 0)
        } else {
            cash_credit.setTitle("Credit", for: .normal)
            theVehicle.set(key: cashCreditKey, value: 1)
        }
    }
    
    // ... and fill-up or partial
    @IBOutlet weak var partial_fill: UIButton!
    @IBAction func FillOrPartial(_ sender: Any) {
        if partial_fill.currentTitle == "Fill" {
            partial_fill.setTitle("Partial", for: .normal)
            theVehicle.set(key: partialFillKey, value: 0)
        } else {
            partial_fill.setTitle("Fill", for: .normal)
            theVehicle.set(key: partialFillKey, value: 1)
        }
    }

    @IBOutlet weak var measureSystem: UIButton!
    @IBAction func USorMetric(_ sender: Any) {
        if measureSystem.currentTitle == "US" {
            measureSystem.setTitle("Metric", for: .normal)
            theVehicle.set(key: measureSystemKey, value: 1)
        } else {
            measureSystem.setTitle("US", for: .normal)
            theVehicle.set(key: measureSystemKey, value: 0)
        }
    }

    // MARK: statistics
    @IBOutlet weak var labelUnitPerFill: UILabel!
    @IBOutlet weak var minUnitPerFill: UITextField!
    @IBOutlet weak var avgUnitPerFill: UITextField!
    @IBOutlet weak var maxUnitPerFill: UITextField!
    
    @IBOutlet weak var labelDistPerX: UILabel!
    @IBOutlet weak var minDistPerX: UITextField!
    @IBOutlet weak var avgDistPerX: UITextField!
    @IBOutlet weak var maxDistPerX: UITextField!

    @IBOutlet weak var labelCostPerX: UILabel!
    @IBOutlet weak var minCostPerX: UITextField!
    @IBOutlet weak var avgCostPerX: UITextField!
    @IBOutlet weak var maxCostPerX: UITextField!
    
    @IBOutlet weak var totDistance: UITextField!
    @IBOutlet weak var totCost: UITextField!
    @IBOutlet weak var totAmount: UITextField!
    @IBOutlet weak var numFillups: UITextField!
    
    private func displayStats () {
        let numFills = theVehicle.get(key: countKey) as? Double ?? 0.0
        if numFills > 0 {
            // NOTE this is amount (gallons per fillup)
            minUnitPerFill.text = String(format:"%.1f", theVehicle.get(key: "min"+amtKey) as! Double)
            maxUnitPerFill.text = String(format:"%.1f", theVehicle.get(key: "max"+amtKey) as! Double)
            avgUnitPerFill.text = String(format:"%.1f", theVehicle.get(key: "tot"+amtKey) as! Double / numFills)
            labelUnitPerFill.text = unitLabels["unit"]! + "/fill"

            if PerUnit {
                let numTrueFills = theVehicle.get(key: "True" + countKey) as? Double ?? 0.0
                // NOTE this is distance per Unit
                labelDistPerX.text = unitLabels["dist"]! + "/" + unitLabels["unit"]!
                minDistPerX.text = String(format:"%.1f", theVehicle.get(key: "min"+distKey+"PU") as! Double)
                maxDistPerX.text = String(format:"%.1f", theVehicle.get(key: "max"+distKey+"PU") as! Double)
                avgDistPerX.text = String(format:"%.1f", theVehicle.get(key: "tot"+distKey+"PU") as! Double / numTrueFills)

                // NOTE this is Cost ($$ per Unit)
                labelCostPerX.text = currencySymbol + "/" + unitLabels["unit"]!
                minCostPerX.text = String(format:"%.2f", theVehicle.get(key: "min"+costKey+"PU") as! Double)
                maxCostPerX.text = String(format:"%.2f", theVehicle.get(key: "max"+costKey+"PU") as! Double)
                avgCostPerX.text = String(format:"%.2f", theVehicle.get(key: "tot"+costKey+"PU") as! Double / numFills)
            } else {
                // NOTE this is distance per FillUp
                labelDistPerX.text = unitLabels["dist"]! + "/fill"
                minDistPerX.text = String(format:"%.1f", theVehicle.get(key: "min"+distKey) as! Double)
                maxDistPerX.text = String(format:"%.1f", theVehicle.get(key: "max"+distKey) as! Double)
                avgDistPerX.text = String(format:"%.1f", theVehicle.get(key: "tot"+distKey) as! Double / numFills)

                // NOTE this is Cost ($$ per fillup)
                labelCostPerX.text = currencySymbol + "/fill"
                minCostPerX.text = String(format:"%.2f", theVehicle.get(key: "min"+costKey) as! Double)
                maxCostPerX.text = String(format:"%.2f", theVehicle.get(key: "max"+costKey) as! Double)
                avgCostPerX.text = String(format:"%.2f", theVehicle.get(key: "tot"+costKey) as! Double / numFills)
            }
        }
        totDistance.text = String(format:"%.0f", theVehicle.get(key: "tot"+distKey) as! Double)
        totCost.text = String(format:"%.0f", theVehicle.get(key: "tot"+costKey) as! Double)
        totAmount.text = String(format:"%.0f", theVehicle.get(key: "tot"+amtKey) as! Double)
        numFillups.text = String(format:"%.0f", numFills)
    }
    
    
    @IBAction func SharingPopUp(_ sender: Any) {
        let csvText = GasEntry.createCSVfromDB()
        print("CSV: \(csvText)")
        
        let tmpDir = FileManager.default.temporaryDirectory
        let today = myDate.string(from: Date.init())
        let fileURL = tmpDir.appendingPathComponent("GasEntryData-\(today)").appendingPathExtension("csv")
        print("FilePath: \(fileURL.path)")

        do {
            try csvText.write(toFile: fileURL.path, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("cannot write file. \(error.code)")
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }

        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [fileURL], applicationActivities: nil)

        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.unknown
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Anything you want to exclude (all I want is email and save to iCloud, Dropbox, or airdrop
        activityViewController.excludedActivityTypes = [
            UIActivityType.addToReadingList,
            UIActivityType.assignToContact,
            UIActivityType.print,
            UIActivityType.saveToCameraRoll
        ]
 
        // this activates the popup view controller
        self.present(activityViewController, animated: true, completion: {})
    }
    
    // MARK: scene controls
    override func viewDidLoad() {
        print ("DEFAULT SCREEN LOADED")
        super.viewDidLoad()
        
        GasEntry.recalcStats()
        displayStats()

        defVehicle.text = currentVehicle
        defFuel.text    = fuelTypePickerValues [theVehicle.get(key: fuelTypeKey) as! Int]
    }

    override func viewDidDisappear(_ animated: Bool)  {
        super.viewDidDisappear(animated)
        
        GasEntry.recalcStats()
        print ("DEFAULT SCREEN WENT AWAY")
    }

}

