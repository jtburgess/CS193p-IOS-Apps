//
//  Vehicle+CoreDataProperties.swift
//  
//
//  Created by John Burgess on 12/16/17.
//
//

import Foundation
import CoreData


extension Vehicle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Vehicle> {
        return NSFetchRequest<Vehicle>(entityName: "Vehicle")
    }

    @NSManaged public var vehicleName: String
    @NSManaged public var fillups: NSSet?

}

// MARK: Generated accessors for fillups
extension Vehicle {

    @objc(addFillupsObject:)
    @NSManaged public func addToFillups(_ value: GasEntry)

    @objc(removeFillupsObject:)
    @NSManaged public func removeFromFillups(_ value: GasEntry)

    @objc(addFillups:)
    @NSManaged public func addToFillups(_ values: NSSet)

    @objc(removeFillups:)
    @NSManaged public func removeFromFillups(_ values: NSSet)

}
