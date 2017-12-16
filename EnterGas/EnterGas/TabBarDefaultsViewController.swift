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
let vehicleNameKey = "vehicleName"
var currentVehicle : String? = nil
let emailAddressKey = "emailAddress"
var currentEmailAddress : String? = nil

class TabBarDefaultsViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("TabBarDefaults did load!")

        if let tmp = defaults.string(forKey: vehicleNameKey) {
            currentVehicle = tmp
        } else {
            // need to assign a default vehicle - segue to that screen
        }
    }

    /*
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
