//
//  Brand+CoreDataClass.swift
//  EnterGas
//
//  Created by John Burgess on 11/10/17.
//  Copyright © 2017 JTBURGESS. All rights reserved.
//
//

import Foundation
import CoreData


public class Brand: NSManagedObject {
    // New() probably be an init()?
    fileprivate class func New (theBrand:String, context:NSManagedObjectContext) -> Brand {
        let brand = NSEntityDescription.insertNewObject(forEntityName: "Brand", into: context) as? Brand
        print("create new Brand Entity: \(theBrand).")
        brand!.brandName = theBrand
        return brand!
    }

    // request a single brand. If it doesnt exist, add it
    class func FindOrAdd(theBrand: String, context: NSManagedObjectContext) -> Brand {
        let request: NSFetchRequest<Brand> = Brand.fetchRequest()
        request.predicate = NSPredicate(format: "brandName = %@", theBrand)
        request.sortDescriptors = [NSSortDescriptor(key: "brandName", ascending: true)]
        
        print("Request Brand \(theBrand)")
        do {
            let result =  try context.fetch(request)
            switch result.count {
                case 1:
                    return result[0] as Brand
                case 0:
                    return New (theBrand:theBrand, context:context)
                default:
                    print("Warn: More than one (\(result.count)) Brand returned for \(theBrand)")
                    return result[0] as Brand
            }
        } catch let error as NSError {
            // ToDo - add brand here
            print("Brand Fetch error: \(error.domain), userInfo: \(error.userInfo)")
            return New (theBrand:theBrand, context:context)
        }
    }
        
    // get list of brand names, sorted by name (not Brand Entries, just the names)
    class func RequestAll( context: NSManagedObjectContext) -> NSArray? {
        let request: NSFetchRequest<Brand> = Brand.fetchRequest()
        // request.predicate = NSPredicate(format: "all")
        request.sortDescriptors = [NSSortDescriptor(key: "brandName", ascending: true,
            selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
            )]
        
        do {
            let allBrands = try context.fetch(request) as NSArray
            var brandList: [String] = []
            for entry in allBrands {
                if let brand = entry as? Brand {
                    brandList.append(brand.brandName)
                    print("append brand: \(brand.brandName)")
                }
            }
            return brandList as NSArray
        } catch let error as NSError {
            print("brand RequestAll error \(error.code), \(error.userInfo)")
            return []
        }
    }
}
