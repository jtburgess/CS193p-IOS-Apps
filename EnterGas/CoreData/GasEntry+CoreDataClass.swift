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

    // gets the most recent earlier entry BY DATE. doesn't check if the odometer is less as it should be
    class func getPrevious(context: NSManagedObjectContext, theDate: TimeInterval) -> GasEntry? {
        let request: NSFetchRequest<GasEntry> = GasEntry.fetchRequest()
        print("getPrevious to date=\(theDate)")
        request.predicate = NSPredicate(format: "date.timeIntervalSince1970 < %f and vehicle.vehicleName = %@", theDate - 1, currentVehicle)
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
 
    // MARK: called from new (or update) GasEntry
    class func save(brand: String?, odometer: String?, toEmpty: String?,
              cost: String?, amount: String?, vehicleName: String?,
              note: String?, fuelType: String?, date: String?,
              cash_credit: Bool?, partial_fill: Bool?,
              validate: Bool = true) -> String {

        //print ("GasEntry SAVE")
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let myContext: NSManagedObjectContext = container.viewContext
        if let gasEntry = NSEntityDescription.insertNewObject(forEntityName: "GasEntry", into: myContext) as? GasEntry {
            return gasEntry.update(brand: brand, odometer: odometer, toEmpty: toEmpty,
                   cost: cost, amount: amount, vehicleName: vehicleName,
                   note: note, fuelType: fuelType, date: date,
                   cash_credit: cash_credit, partial_fill: partial_fill,
                   validate: validate)
        } else {
            print ("Error creating new gasEntry")
            return "Error creating new gasEntry"
        }
    }
    
    func update (brand: String?, odometer: String?, toEmpty: String?,
                       cost: String?, amount: String?, vehicleName: String?,
                       note: String?, fuelType: String?, date: String?,
                       cash_credit: Bool?, partial_fill: Bool?,
                       validate: Bool = true) -> String {

        //print("GasEntry UPDATE")
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        var errors = ""
        
        // brand list validataions
        let theBrand = (brand ?? "").trimmingCharacters(in: [" "])
        if theBrand == "" {
            errors.append ("Please fill in the Brand purchased\n")
        }
        
        var theOdo : Int = -1
        if odometer!.range(of: ".") == nil {
            if let tmp = formatter.number(from: odometer!) as! NSInteger? {
                theOdo = tmp
            }
        } else {
            errors.append("Bad Odometer value, must be an integer\n")
        }
        
        var milesLeft : Int = 0
        if toEmpty!.range(of: ".") == nil {
            if let tmp = formatter.number(from: toEmpty!) as! NSInteger? {
                milesLeft = tmp
            }
        } else {
            // missing milesLeft is not an error
            errors.append("Bad miles left value, must be an integer\n")
        }
        
        var theCost: NSDecimalNumber = -1
        if let tmp = formatter.number(from: cost!) as! Double? {
            if tmp < 1.0 || tmp > 999.9 {
                errors.append("cost outside expected range (1 - 1000)\n")
            } else {
                theCost = formatter.number(from: cost!) as! NSDecimalNumber
            }
        } else {
            errors.append("Bad Cost value\n")
        }
        
        var theAmount: NSDecimalNumber = -1
        if let tmp = formatter.number(from: amount!) as! Double? {
            if tmp < 1.0 || tmp > 999.9 {
                errors.append("amount outside expected range (1 - 1000)\n")
            } else {
                theAmount = formatter.number(from: amount!) as! NSDecimalNumber
            }
        } else {
            errors.append("Bad Amount value\n")
        }
        
        let theVehicle = (vehicleName ?? "").trimmingCharacters(in: [" "])
        if theVehicle == "" {
            errors.append ("Please fill in a vehicle name\n")
        } else {
            // set the current and default Vehicles
            currentVehicle = theVehicle
            defaults.setValue(theVehicle, forKey: vehicleNameKey)
        }
        
        var theDate : TimeInterval
        if let tmpDate = date {
            //theDate = dateFromString(dateString: tmpDate).timeIntervalSince1970
            theDate = myDate.timeInterval(from:tmpDate)
        } else {
            // now()
            theDate = Date.init().timeIntervalSince1970
        }
        //let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        //let myContext: NSManagedObjectContext = container.viewContext
        
        // calculate dist from last fillup; needed to calc MPG
        if let prevGasEntry = GasEntry.getPrevious(context: self.managedObjectContext!, theDate: theDate) {
            let prevOdo = OptInt.int(from: prevGasEntry.odometer!)
            let distance = (theOdo - prevOdo)
            if distance < 1 || distance > 999 {
                errors.append ("distance from last fill up (\(distance)) is outside expected range (1 - 1000). Check the odometer value\n")
            } else {
                self.distance = NSDecimalNumber(value:distance)
            }
        } else {
            self.distance =  NSDecimalNumber(value:theOdo)
        }
        
        print ("Save this Entry: brand=\(theBrand), odo=\(theOdo), cost=\(theCost), gals=\(theAmount), vehicle=\(theVehicle)")
        
        if errors != "" && validate {
            print ("There are errors")
            return errors
        }

        //print("create gasentry Entity")
        let brandEntry = Brand.FindOrAdd(theBrand:theBrand, context:self.managedObjectContext!)
        self.brand = brandEntry
        
        let vehicleEntry = Vehicle.FindOrAdd(theVehicle:theVehicle, context:self.managedObjectContext!)
        vehicle = vehicleEntry
        print("created Brand and Vehicle Entity links")
        
        self.date = theDate
        self.odometer = NSDecimalNumber(value:theOdo)
        self.toEmpty  = NSDecimalNumber(value:milesLeft)
        self.cost    = theCost
        self.amount  = theAmount
        self.note    = note ?? ""
        self.cash_credit = cash_credit as NSNumber?
        self.partial_fill = partial_fill as NSNumber?
        self.fuelTypeID = currentFuelTypeID as NSNumber

        do {
            try self.managedObjectContext?.save()
        } catch let error as NSError  {
            print("Core Data Save Error: \(error.code)")
        }

        print("gasentry Entity saved")

        return errors
    }

    func delete () {
        print ("GasEntry Delete called: \(String(describing: self.vehicle?.vehicleName)), \(String(describing: self.odometer)), \(String(describing: self.date))")
        let context = self.managedObjectContext!
        context.delete(self)
        do {
            try context.save()
            // OK
        } catch let error as NSError  {
            print("Core Data Save Error: \(error.code)")
        }
    }

    class func recalcDistances() {
        let myContext: NSManagedObjectContext = (((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext))!
        // get the entire table, but only the current vehicles, newest first
        // then walk the array backwards, working on the Next entry, using the odometer from the Prev entry
        var gasEntryArray = (GasEntry.RequestAll( vehicleName: currentVehicle, context: myContext) as? Array<GasEntry>)!
        var thisEntry = gasEntryArray[0]
        gasEntryArray.remove(at: 0)
        for prevEntry in gasEntryArray {
            let theOdo  = OptInt.int(from: thisEntry.odometer!)
            let prevOdo = OptInt.int(from: prevEntry.odometer!)
            let distance = OptInt.int(from: thisEntry.distance!)
            let newDistance = (theOdo - prevOdo)
            if distance != newDistance {
                print ("distance changed for \(thisEntry.date); was \(distance), now \(newDistance)")
                thisEntry.distance = NSDecimalNumber(value:newDistance)
                do {
                    try thisEntry.managedObjectContext?.save()
                } catch let error as NSError  {
                    print("Core Data Save Error: \(error.code)")
                }
            }
            
            thisEntry = prevEntry
        }
    }

    class func createCSVfromDB() -> String {
        let myContext: NSManagedObjectContext = (((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext))!
        // get the entire table, ALL vehicles
        
        // harded coded header; can't use reduce since I need to get linked values, and format the date
        var csvString: String = "Vehicle,Brand,date,odometer,toEmpty,cost,amount,fuelType,note\n"
        
        let objects = (GasEntry.RequestAll( vehicleName: "all", context: myContext) as? Array<GasEntry>)!
        
        // combine all rows into \n separated lines, with ',' between items -- no comma escaping with ".. , .."
        for myData in objects {
            let vehicle = myData.vehicle?.vehicleName ?? "error"
            let brand  = myData.brand?.brandName ?? "error"
            if vehicle == "error" || brand == "error" {
                // delete bogus entry
                myData.delete()
                continue
            }

            let amount = String(format:"%.1f", ((myData.amount)! as Double) )
            let cost   = String(format:"%.2f", ((myData.cost)! as Double) )
            let date   = myDate.string (fromInterval: (myData.date))
            let odometer = OptInt.string (from: myData.odometer)
            let toEmpty  = OptInt.string (from: myData.toEmpty)
            let note   = myData.note ?? ""
            let fuelType = fuelTypePickerValues[ myData.fuelTypeID as? Int ?? 0 ]
            
            csvString += "\(vehicle),\(brand),\(date),\(odometer),\(toEmpty),\(cost),\(amount),\(fuelType),\(note)\n"
        }
        return csvString
    }
}
