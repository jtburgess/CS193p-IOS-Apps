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

    fileprivate class func New (theVehicleName:String, context:NSManagedObjectContext) -> Vehicle {
        let vehicle = NSEntityDescription.insertNewObject(forEntityName: "Vehicle", into: context) as? Vehicle
        print("create new Vehicle Entity: \(theVehicleName).")
        vehicle!.vehicleName = theVehicleName
        return vehicle!
    }
    
    // request a single vehicle. If it doesnt exist, add it
    class func FindOrAdd(theVehicleName: String, context: NSManagedObjectContext) -> Vehicle {
        let request: NSFetchRequest<Vehicle> = Vehicle.fetchRequest()
        request.predicate = NSPredicate(format: "vehicleName = %@", theVehicleName)
        request.sortDescriptors = [NSSortDescriptor(key: "vehicleName", ascending: true)]
        
        print("Request Vehicle \(theVehicleName)")
        do {
            let result =  try context.fetch(request)
            switch result.count {
            case 1:
                return result[0] as Vehicle
            case 0:
                let newVehicle = New (theVehicleName:theVehicleName, context:context)
                return newVehicle
            default:
                print("Warn: More than one (\(result.count)) Vehicle returned for \(theVehicleName)")
                return result[0] as Vehicle
            }
        } catch let error as NSError {
            // ToDo - add Vehicle here
            print("Vehicle Fetch error: \(error.code)")
            return New (theVehicleName:theVehicleName, context:context)
        }
    }
    
    // get list of Vehicle names, sorted by name (not Vehicle Entries, just the names)
    class func RequestAll( ) -> NSArray? {
        let request: NSFetchRequest<Vehicle> = Vehicle.fetchRequest()
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let context: NSManagedObjectContext = container.viewContext

        //request.predicate = NSPredicate(format: "all")
        request.sortDescriptors = [NSSortDescriptor(key: "vehicleName", ascending: true,
                    selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
            )]
        
        do {
            let allVehicles = try context.fetch(request) as NSArray
            var vehicleList: [String] = []
            for entry in allVehicles {
                if let vehicle = entry as? Vehicle {
                    if vehicle.fillups!.count > 0 {
                        vehicleList.append(vehicle.vehicleName)
                        print("append Vehicle: \(vehicle.vehicleName)")
                    } else {
                        print("skip unused vehicle: \(vehicle.vehicleName)")
                    }
                }
            }
            return vehicleList as NSArray
        } catch let error as NSError {
            print("Vehicle RequestAll error \(error.code), \(error.userInfo)")
            return []
        }
    }

}
