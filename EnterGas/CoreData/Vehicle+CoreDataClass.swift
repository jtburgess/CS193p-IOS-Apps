//
//  Vehicle+CoreDataClass.swift
//  
//
//  Created by John Burgess on 12/16/17.
//
//

import Foundation
import CoreData

@objc(Vehicle)
public class Vehicle: NSManagedObject {

    fileprivate class func New (theVehicle:String, context:NSManagedObjectContext) -> Vehicle {
        let vehicle = NSEntityDescription.insertNewObject(forEntityName: "Vehicle", into: context) as? Vehicle
        print("create new Vehicle Entity: \(theVehicle)")
        vehicle!.vehicleName = theVehicle
        return vehicle!
    }
    
    // request a single vehicle. If it doesnt exist, add it
    class func FindOrAdd(theVehicle: String, context: NSManagedObjectContext) -> Vehicle {
        let request: NSFetchRequest<Vehicle> = Vehicle.fetchRequest()
        request.predicate = NSPredicate(format: "vehicleName = %@", theVehicle)
        request.sortDescriptors = [NSSortDescriptor(key: "vehicleName", ascending: true)]
        
        print("Request Vehicle \(theVehicle)")
        do {
            let result =  try context.fetch(request)
            switch result.count {
            case 1:
                return result[0] as Vehicle
            case 0:
                let newVehicle = New (theVehicle:theVehicle, context:context)
                // initialize the gas entry list for this vehicle.
                _ = GasEntry.defaultEntry()
                return newVehicle
            default:
                print("Warn: More than one (\(result.count)) Vehicle returned for \(theVehicle)")
                return result[0] as Vehicle
            }
        } catch {
            // ToDo - add Vehicle here
            print("Vehicle Fetch error: \(error)")
            return New (theVehicle:theVehicle, context:context)
        }
    }
    
    // get list of Vehicle names, sorted by name (not Vehicle Entries, just the names)
    class func RequestAll( context: NSManagedObjectContext) -> NSArray? {
        let request: NSFetchRequest<Vehicle> = Vehicle.fetchRequest()
        request.predicate = NSPredicate(format: "all")
        request.sortDescriptors = [NSSortDescriptor(key: "vehicleName", ascending: true,
                                                    selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
            )]
        
        do {
            let allVehicles = try context.fetch(request) as NSArray
            var vehicleList: [String] = []
            for entry in allVehicles {
                if let vehicle = entry as? Vehicle {
                    vehicleList.append(vehicle.vehicleName)
                    print("append Vehicle: \(vehicle.vehicleName)")
                }
            }
            return vehicleList as NSArray
        } catch {
            let nserror = error as NSError
            print("Vehicle RequestAll error \(nserror), \(nserror.userInfo)")
            return []
        }
    }

}
