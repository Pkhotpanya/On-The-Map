//
//  OTMUtility.swift
//  On The Map
//
//  Created by Peter Khotpanya on 11/3/16.
//  Copyright © 2016 Peter Khotpanya. All rights reserved.
//
//  App functions that are shared among ViewControllers.

import UIKit

protocol OTMUtility {}

extension OTMUtility where Self: UIViewController{
    
    func OTMLoginChecker() {
        if (UDBClient.shared.sessionID?.isEmpty)! {
            //self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }
    }
    
    func OTMSignUp(){
        UIApplication.shared.open(NSURL(string: "https://www.udacity.com/account/auth#!/signup") as! URL, options:[:], completionHandler: nil)
    }
    
    func OTMLogin(username: String, password: String){
        UDBClient.shared.postASession(username: username, password: password, completion: { (success) in
            if !success {
                let alert=UIAlertController(title: "Failed to login", message: "", preferredStyle: UIAlertControllerStyle.alert);
                //show it
                self.show(alert, sender: self);
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func OTMLogOut() {
        UDBClient.shared.deleteASession { (success) in
            if success {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
    }
    
    func OTMAddPin() {
        if !(UDBClient.shared.studentInformation?.objectId.isEmpty)! {
            let alert=UIAlertController(title: "Are you sure you want to overwrite existing location?", message: "", preferredStyle: UIAlertControllerStyle.alert);
            
            let accept = UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) in
                self.performSegue(withIdentifier: "addPinSegue", sender: nil)
            })
            let cancel = UIAlertAction(title: "No thanks.", style: .cancel, handler: { (alertAction) in
                alert.dismiss(animated: true, completion: nil)
            })
            
            alert.addAction(accept)
            alert.addAction(cancel)
            
            self.show(alert, sender: self);
        }
    }
    
    func OTMRefreshPins(){
        //Add activity indicator here
        
        UDBClient.shared.getStudentLocations(limit: 100, skip: 0, order: .updatedAt, completion: { (success) in
            if success {
                NotificationCenter.default.post(name: UDBClient.Constants.ReloadLocationViewsNotification, object: nil)
            }
        })
    }
    
    func OTMCancelAddingPin(){
        
    }
    
    func OTMFindLocationOnTheMap(){
        
    }
    
    func OTMSubmitStudentLocation(){
        
    }
}
