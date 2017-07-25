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
                imageVC.title = (sender as? UIButton)?.currentTitle
            } else {
                print ("segue ERROR: destination is not an ImageViewController")
            }
        } else {
            print ("segue ERROR: no url at \(segue.identifier ?? "NIL")")
        }
        
    }

}

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
