//
//  CassiniViewController.swift
//  Cassini
//
//  Created by John Burgess on 7/24/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class CassiniViewController: UIViewController, UISplitViewControllerDelegate {

    override func awakeFromNib() {
        // first make me the delegate, then see below
        // this makes THIS view the first one you see
        super.awakeFromNib()
        self.splitViewController?.delegate = self
    }
    
    // MARK:Nagigation
    func splitViewController(_ splitViewController: UISplitViewController,
                collapseSecondary secondaryViewController: UIViewController,
                onto primaryViewController: UIViewController
        ) -> Bool {
        if primaryViewController.contents == self {
            // this allows THIS view to show up on launch, inscread of a blank screen
            if let ivc = secondaryViewController.contents as? ImageViewController, ivc.imageURL == nil {
                return true
            }
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let url = DemoURL.NASA[segue.identifier ?? ""] {
            print ("segue to image \(url)")
            if let imageVC = (segue.destination.contents as? ImageViewController) {
                imageVC.imageURL = url
                // (or use sender.identifier, since we set that to be the same)
                imageVC.title = (sender as? UIButton)?.currentTitle
            } else {
                print ("segue ERROR: destination is not an ImageViewController")
            }
        } else {
            print ("segue ERROR: no url at \(segue.identifier ?? "NIL")")
        }
        
    }

}

// clever way to automatically get the actual visible view controller when embedded in a Nav VC
extension UIViewController
{
    var contents: UIViewController {
        get {
            if let navCon = self as? UINavigationController {
                return navCon.visibleViewController ?? self
            } else {
                return self
            }
        }
    }
}
