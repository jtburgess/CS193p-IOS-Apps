//
//  GasEntry+CoreDataProperties.swift
//  EnterGas
//
//  Created by John Burgess on 11/10/17.
//  Copyright © 2017 JTBURGESS. All rights reserved.
//
//

import Foundation
import CoreData


extension GasEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GasEntry> {
        return NSFetchRequest<GasEntry>(entityName: "GasEntry")
    }

    @NSManaged public var amount: NSDecimalNumber?
    @NSManaged public var cost: NSDecimalNumber?
    @NSManaged public var date: TimeInterval
    @NSManaged public var odometer: NSDecimalNumber?
    @NSManaged public var toEmpty: NSDecimalNumber?
    @NSManaged public var brand: Brand?

}
