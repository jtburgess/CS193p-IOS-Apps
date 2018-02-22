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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func SharingPopUp(_ sender: Any) {
        let csvText = createCSVfromDB()
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
    
    func createCSVfromDB() -> String {
        let myContext: NSManagedObjectContext = (((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext))!
        // get the entire table, ALL vehicles

        // harded coded header; can't use reduce since I need to get linked values, and format the date
        var csvString: String = "Vehicle,Brand,date,cost,odometer,toEmpty,amount,fuelType,note\n"

        let objects = (GasEntry.RequestAll( vehicleName: "all", context: myContext) as? Array<GasEntry>)!
        /* shouldn't need this
         guard objects.count > 0 else {
             return ""
         }
         */

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone (abbreviation:"EST5EDT")

        // combine all rows into \n separated lines, with ',' between items -- no comma escaping with ".. , .."
        for myData in objects {
            let vehicle = myData.vehicle?.vehicleName ?? "error"
            let brand  = myData.brand?.brandName ?? "error"

            let amount = String(format:"%.1f", ((myData.amount)! as Double) )
            let cost   = String(format:"%.2f", ((myData.cost)! as Double) )
            let date   = dateFormatter.string(from: Date(timeIntervalSince1970: (myData.date)))
            let odometer = String(format:"%d", (myData.odometer)! as Int)
            let toEmpty  = String(format:"%d", (myData.toEmpty)! as Int)
            let note   = myData.note ?? ""
            let fuelType = fuelTypePickerValues[ myData.fuelTypeID as? Int ?? 0 ]
            
            csvString += "\(vehicle),\(brand),\(date),\(cost),\(odometer),\(toEmpty),\(amount),\(fuelType!),\(note),\\n"
        }
        return csvString
    }
}

