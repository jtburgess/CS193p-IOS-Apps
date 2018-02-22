//
//  GasEntry+CoreDataClass.swift
//  EnterGas
//
//  Created by John Burgess on 11/10/17.
//  Copyright © 2017 JTBURGESS. All rights reserved.
//
//

import Foundation
import CoreData

public class GasEntry: NSManagedObject {
    class func RequestAll( vehicleName: String?, context: NSManagedObjectContext) -> NSArray?
    {
        if let theVehicle = vehicleName {

            let request: NSFetchRequest<GasEntry> = GasEntry.fetchRequest()
            if theVehicle != "all" {
                request.predicate = NSPredicate(format: "vehicle.vehicleName = %@", theVehicle)
            } // else request ALL entries
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            do {
                let allEntries = try context.fetch(request) as NSArray
                print ("RequestAll GasEntrys returned \(allEntries.count)")
                return allEntries
            } catch let error as NSError {
                print("GasEntry RequestAll error \(error.code), \(error.userInfo)")
            }
        }
        return []
    }

    class func getPrevious(context: NSManagedObjectContext, theDate: TimeInterval) -> GasEntry? {
        let request: NSFetchRequest<GasEntry> = GasEntry.fetchRequest()
        print("getPrevious to date=\(theDate)")
        request.predicate = NSPredicate(format: "date.timeIntervalSince1970 <= %f and vehicle.vehicleName = %@", theDate, currentVehicle)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1
        do {
            let result = try context.fetch(request) as NSArray
            if result.count != 1 {
                print ("No previous")
                return nil
            }
            if let theGasEntry = result[0] as? GasEntry {
                print ("getPrevious \(theDate) returned odo=\(String(describing: theGasEntry.odometer)), date=\(String(describing:theGasEntry.date))")
                return theGasEntry
            }
        } catch let error as NSError {
            print("getPrevious GasEntry error \(error.code), \(error.userInfo)")
        }
        return nil
    }
    
    class func defaultEntry () -> GasEntry? {
        if currentVehicle == "none" {
            // can't do anything until we have an assigned vehicle for this session
            return nil
        }
        let myContext: NSManagedObjectContext = (((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext))!
        if let gasEntry = NSEntityDescription.insertNewObject(forEntityName: "GasEntry", into: myContext) as? GasEntry {
            print("create Test gasentry Entity for \(currentVehicle)")
            let brandEntry = Brand.FindOrAdd(theBrand:"initialize", context:gasEntry.managedObjectContext!)
            gasEntry.brand = brandEntry
            print("created Brand Entity link")
            
            let vehicleEntry = Vehicle.FindOrAdd(theVehicle: currentVehicle, context: gasEntry.managedObjectContext!)
            gasEntry.vehicle = vehicleEntry
            print("created Vehicle Entity link")

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            gasEntry.date = (dateFormatter.date(from: "2010-01-01"))!.timeIntervalSince1970
            print ("set date 2017-01-01 = \(gasEntry.date)")
            gasEntry.odometer = 0
            gasEntry.cost = 0
            gasEntry.amount = 0
            return gasEntry
        }
        return nil
    }
}
