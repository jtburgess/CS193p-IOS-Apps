//
//  TabBarDefaultsViewController.swift
//  EnterGas
//
//  Created by John Burgess on 12/16/17.
//  Copyright © 2017 JTBURGESS. All rights reserved.
//

import UIKit


// user preferences aka UserDefaults
let defaults = UserDefaults.standard

// all of the "current" values are not optional. I supply real defaults
let vehicleNameKey = "vehicleName"
var currentVehicle : String = "none"

// fuelTypeID is used as the index into fuelTypePickerValues for display purposes
var fuelTypeKey = "fuelType"
var currentFuelTypeID : Int = 0

let emailAddressKey = "emailAddress"
var currentEmailAddress : String = "none"

class TabBarDefaultsViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if  let anyValue = defaults.object(forKey: vehicleNameKey),
            let tmp = anyValue as? String {
            currentVehicle = tmp
        } else {
            // need to assign a default vehicle - segue to that screen
            print("no default vehicle")
        }

        if  let anyValue = defaults.object(forKey: fuelTypeKey),
            let tmp = anyValue as? Int {
            currentFuelTypeID = tmp
        } else {
            // need to assign a default fuel type - segue to that screen
            // for now default to regular
            currentFuelTypeID = 0
            print ("no default fuel type")
        }

        if  let anyValue = defaults.object(forKey: emailAddressKey),
            let tmp = anyValue as? String {
            currentEmailAddress = tmp
        } else {
            // need to assign a default email address - segue to that screen
        }
        print("TabBarDefaults did load: vehicle=\(currentVehicle), currentFuelID=\(currentFuelTypeID)")
    }
}
