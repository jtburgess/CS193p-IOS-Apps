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
                    _ = Vehicle.FindOrAdd(theVehicle: theVehicleName, context: context)
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

    // MARK: statistics
    @IBOutlet weak var minMPG: UITextField!
    @IBOutlet weak var avgMPG: UITextField!
    @IBOutlet weak var maxMPG: UITextField!

    @IBOutlet weak var minMPFill: UITextField!
    @IBOutlet weak var avgMPFill: UITextField!
    @IBOutlet weak var maxMPFill: UITextField!

    @IBOutlet weak var minCostPG: UITextField!
    @IBOutlet weak var avgCostPG: UITextField!
    @IBOutlet weak var maxCostPG: UITextField!
    
    private func displayStats () {
        let numFills = theVehicle.get(key: countKey) as? Double ?? 0.0
        if numFills > 0 {
            minMPFill.text = String(format:"%.2f", theVehicle.get(key: "min"+distKey) as! Double)
            maxMPFill.text = String(format:"%.2f", theVehicle.get(key: "max"+distKey) as! Double)
            avgMPFill.text = String(format:"%.2f", theVehicle.get(key: "tot"+distKey) as! Double / numFills)

        }

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

