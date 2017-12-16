//
//  GasListTableViewController.swift
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
    override func viewDidLoad() {
        print("TableView DidLoad")
        super.viewDidLoad()
        // if the list is empty or doesn't have a proper initialze entry, then initialize it!
        let myContext: NSManagedObjectContext = (((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext))!
        let initList = (GasEntry.RequestAll(vehicleName:currentVehicle, context:myContext) as? Array<GasEntry>)!
        if initList.count == 0 {
            initializeHistory()
        /*****
         } else if initList.last!.brand?.brandName != "initialize" {
            print("brand.last=\(String(describing: initList.last!.brand?.brandName)), count=\(initList.count)")
            for entry in initList {
                print("delete!")
                myContext.delete (entry)
            }
            initializeHistory()
         *****/
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("TableView WillAppear")
        loadFromCoreData()
    }
    func loadFromCoreData () {
        let myContext: NSManagedObjectContext = (((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext))!
        gasList = (GasEntry.RequestAll(vehicleName: currentVehicle, context:myContext) as? Array<GasEntry>)!
        print("loaded \(gasList.count) entries")
    }
    // load initial row
    func initializeHistory() {
        print ("Insert Initial Row")
        if let _ = GasEntry.defaultEntry() {
           do {
                let myContext: NSManagedObjectContext = (((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext))!
                try myContext.save()
            } catch let error {
                print("Core Data Save Error: \(error)")
            }
        }
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
        let dqCell = tableView.dequeueReusableCell(withIdentifier: "gasEntryCell", for: indexPath)

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

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print ("segue to Entry screen; not used with Tab View Controller")
    }

}
