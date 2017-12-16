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

    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<GasEntry> {
        return NSFetchRequest<GasEntry>(entityName: "GasEntry")
    }

    @NSManaged public var amount: NSDecimalNumber? // num gallons in this fillup
    @NSManaged public var cost: NSDecimalNumber?   // $$
    @NSManaged public var date: TimeInterval      // todays date in sec-since-1970
    @NSManaged public var odometer: NSDecimalNumber?
    @NSManaged public var distance: NSDecimalNumber? // distance since prior fillup
    @NSManaged public var toEmpty: NSDecimalNumber?  // optional miles until totally empty
    @NSManaged public var note: String?

    @NSManaged public var brand: Brand?         // link to Brand entry
    @NSManaged public var vehicle: Vehicle?     // link to vehicleName entry

}
