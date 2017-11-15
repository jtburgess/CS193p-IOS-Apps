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
        // clear the list (delete), then re-init
        let myContext: NSManagedObjectContext = (((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext))!
        let delList = (GasEntry.RequestAll(context:myContext) as? Array<GasEntry>)!
        for entry in delList {
            print("delete!")
            myContext.delete (entry)
        }
        loadTestData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("TableView WillAppear")
        loadFromCoreData()
    }
    func loadFromCoreData () {
        let myContext: NSManagedObjectContext = (((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext))!
        gasList = (GasEntry.RequestAll(context:myContext) as? Array<GasEntry>)!
        print("loaded \(gasList.count) entries")
    }
    // load test data
    func loadTestData() {
        print ("Insert TestData")
        let myContext: NSManagedObjectContext = (((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext))!
        if let gasEntry = NSEntityDescription.insertNewObject(forEntityName: "GasEntry", into: myContext) as? GasEntry {
            print("create Test gasentry Entity")
            let brandEntry = Brand.Request(theBrand:"theBrand", context:gasEntry.managedObjectContext!)
            gasEntry.brand = brandEntry
            print("created Brand Entity link")

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            gasEntry.date = (dateFormatter.date(from: "2017-01-01"))!.timeIntervalSince1970
            print ("set date 2017-01-01 = \(gasEntry.date)")
            gasEntry.odometer = 100
            gasEntry.cost = 99.9
            gasEntry.amount = 9.9
            gasList.append ( gasEntry )
            
            do {
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
        if let gasEntryCell = dqCell as? GasEntryCellTableViewCell {
            if indexPath.row == 0 {
                gasEntryCell.updateHeader()
            } else {
                let data = gasList[indexPath.row-1]
                gasEntryCell.myData = data
            }
            
        }
        // Configure the cell...

        return dqCell
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
