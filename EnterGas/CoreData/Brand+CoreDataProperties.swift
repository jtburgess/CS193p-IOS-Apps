//
//  Brand+CoreDataProperties.swift
//  EnterGas
//
//  Created by John Burgess on 11/10/17.
//  Copyright © 2017 JTBURGESS. All rights reserved.
//
//

import Foundation
import CoreData


extension Brand {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Brand> {
        return NSFetchRequest<Brand>(entityName: "Brand")
    }

    @NSManaged public var brandName: String
    @NSManaged public var fillups: NSSet?
}

// MARK: Generated accessors for fillups
/* extension Brand {

    @objc(addFillupsObject:)
    @NSManaged public func addToFillups(_ value: GasEntry)

    @objc(removeFillupsObject:)
    @NSManaged public func removeFromFillups(_ value: GasEntry)

    @objc(addFillups:)
    @NSManaged public func addToFillups(_ values: NSSet)

    @objc(removeFillups:)
    @NSManaged public func removeFromFillups(_ values: NSSet)

}
*/
