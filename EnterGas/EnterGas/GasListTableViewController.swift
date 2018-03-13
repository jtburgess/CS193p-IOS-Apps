//
//  GasListTableViewController.swift?
//  EnterGas
//
//  Created by John Burgess on 10/22/17.
//  Copyright © 2017 JTBURGESS. All rights reserved.
//

import UIKit
import CoreData

class GasListTableViewController: UITableViewController {

    // model -- array (sections) of array of Gas Entrys
    var gasList = Array<GasEntry>() {
        didSet {
            tableView.reloadData()
            // fix -- need to change number of rows and re-display
            // and reloadData is brute force
        }
    }

    // load gasList from the DB
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("TableView WillAppear")
        getDefaults()
        loadFromCoreData()
    }
    
    func loadFromCoreData () {
        let myContext: NSManagedObjectContext = (((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext))!
        gasList = (GasEntry.RequestAll(vehicleName: currentVehicle, context:myContext) as? Array<GasEntry>)!
        print("loaded \(gasList.count) entries")
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // multiple sections aren't implemented
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // num rows is just the size of the gasList
        return gasList.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            let dqCell = tableView.dequeueReusableCell(withIdentifier: "gasTitleCell", for: indexPath)
            if let gasTitleCell = dqCell as? GasTitleCellTableViewCell {
                gasTitleCell.updateHeader()
            } else {
                print("ERROR casting dqCell to GasTitleCellTableViewCell")
            }
            return dqCell
        } else {
            let dqCell = tableView.dequeueReusableCell(withIdentifier: "gasEntryCell", for: indexPath)
            if let gasEntryCell = dqCell as? GasEntryCellTableViewCell {
                let data = gasList[indexPath.row-1]
                gasEntryCell.myData = data
            } else {
                print("ERROR casting dqCell to GasEntryCellTableViewCell")
            }
            return dqCell
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let row = indexPath.row
        print("did select Row: \(row)")
    }
    
    // MARK: - Navigation - segue from the table to the Edit view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print ("Table VC segue to id=\(segue.identifier!)")
        var destVC = segue.destination
        if let navigationVC = destVC as? UINavigationController {
            destVC = navigationVC.visibleViewController ?? destVC
        }
        if let editVC = destVC as? EditFuelPurchaseViewController {
            if let cell = sender as? GasEntryCellTableViewCell,
                let indexPath = tableView.indexPath(for: cell) {
                let selectedRow = indexPath.row
                print("Edit segue, row \(selectedRow)")
                editVC.myData = gasList[selectedRow-1]
            } else {
                print ("sender was not a GasEntryCellTableViewCell")
            }
        } else {
            print ("Error: segue NOT with target EditFuelPurchaseViewController")
        }
    }

    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */

}
