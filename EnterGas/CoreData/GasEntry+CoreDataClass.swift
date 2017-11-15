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
    class func RequestAll( context: NSManagedObjectContext) -> NSArray?
    {
        let request: NSFetchRequest<GasEntry> = GasEntry.fetchRequest()
        //request.predicate = NSPredicate(format: "unique = %@")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let allEntries = try context.fetch(request) as NSArray
            print ("RequestAll GasEntrys returned \(allEntries.count)")
            return allEntries
        } catch {
            let nserror = error as NSError
            print("GasEntry RequestAll error \(nserror), \(nserror.userInfo)")
            return []
        }
    }

}
