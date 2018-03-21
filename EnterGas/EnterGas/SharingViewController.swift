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

    @IBOutlet weak var defVehicle: UITextField!
    @IBOutlet weak var defFuel: UILabel!
    @IBOutlet weak var defEmailAddr: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDefaults()
        // Do any additional setup after loading the view.
    }
    
    private func loadDefaults() {
        defVehicle.text = currentVehicle
        defFuel.text    = fuelTypePickerValues [currentFuelTypeID]
        defEmailAddr.text = currentEmailAddress
    }

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
                    let theVehicle = VehiclePickerValues[i]
                    self.defVehicle.text = theVehicle
                    currentVehicle = theVehicle
                    defaults.setValue(theVehicle, forKey: vehicleNameKey)
                    let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
                    let context: NSManagedObjectContext = container.viewContext
                    _ = Vehicle.FindOrAdd(theVehicle: theVehicle, context: context)
                }
            }
    }

    @IBAction func FuelTypePickerPopup(_ sender: Any) {
        print ("set default fuel type popup")
        GenericPickerDialog(
                pickerView: FuelTypePickerView(frame: CGRect(x: 0, y: 30, width: 300, height: 216))
            ).show(
                startValue: fuelTypePickerValues [currentFuelTypeID],
                title: "Default Fuel Type Picker"
            ) {
            (returnValue) -> Void in
            if let theFuelTypeID = returnValue {
                self.defFuel.text = fuelTypePickerValues [theFuelTypeID]
                currentFuelTypeID = theFuelTypeID
                defaults.setValue(theFuelTypeID, forKey: fuelTypeKey)
            }
        }
    }

    @IBAction func recalcFilupDistances(_ sender: Any) {
        GasEntry.recalcDistances()
    }

    @IBAction func SharingPopUp(_ sender: Any) {
        let csvText = GasEntry.createCSVfromDB()
        print("CSV: \(csvText)")
        
        let tmpDir = FileManager.default.temporaryDirectory
        let fileURL = tmpDir.appendingPathComponent("GasEntryData").appendingPathExtension("csv")
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
}

