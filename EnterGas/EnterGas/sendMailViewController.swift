//
//  sendMailViewController.swift
//  EnterGas
//
//  Created by John Burgess on 1/11/18.
//  Copyright © 2018 JTBURGESS. All rights reserved.
//

import UIKit
import MessageUI

class sendMailViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    func someAction () {
        let mailComposerVC = MFMailComposeViewController()
        
        if MFMailComposeViewController.canSendMail() {
            mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
            
            mailComposerVC.setToRecipients(["someone@somewhere.com"])
            mailComposerVC.setSubject("Your requested GasEntry CSV dump")
            mailComposerVC.setMessageBody("The CSV is attached", isHTML: true)
            //mailComposerVC.addAttachmentData(theCsvStringGoesHere, mimeType: "text/csv", fileName: "GasEntryData.csv")

            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }

    // this displays an alert screen if/when the device isn't set up to do email
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email",
                                                   message: "Please check your e-mail configuration and try again.",
                                                   preferredStyle: UIAlertControllerStyle.alert)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
        //sendMailErrorAlert.show(self, sender: self)
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        print("sendMail complete; result: \(result), error: \(String(describing: error))")
        controller.dismiss(animated: true, completion: nil)
    }
}
