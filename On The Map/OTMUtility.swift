//
//  OTMUtility.swift
//  On The Map
//
//  Created by Peter Khotpanya on 11/3/16.
//  Copyright © 2016 Peter Khotpanya. All rights reserved.
//
//  App functions that are shared among ViewControllers.

import UIKit
import CoreLocation

protocol OTMUtility {}

extension OTMUtility where Self: UIViewController{
    
    func OTMLoginChecker() {
        if (UDBClient.shared.sessionID?.isEmpty)! {
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }
    }
    
    func OTMSignUp(){
        UIApplication.shared.open(NSURL(string: "https://www.udacity.com/account/auth#!/signup") as! URL, options:[:], completionHandler: nil)
    }
    
    func OTMLogin(username: String, password: String){
        startAnimatingActivity()
        
        UDBClient.shared.postASession(username: username, password: password, completion: { (success) in
            if !success {
                //TODO: If the login does not succeed, the user will be presented with an alert view specifying whether it was a failed network connection, or an incorrect email and password.
                DispatchQueue.main.async {
                    self.stopAnimatingActivity(){
                        let alert=UIAlertController(title: "Failed to login", message: "", preferredStyle: UIAlertControllerStyle.alert);
                        let accept = UIAlertAction(title: "Ok", style: .default, handler: { (alertAction) in
                            alert.dismiss(animated: true, completion: nil)
                        })
                        alert.addAction(accept)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.stopAnimatingActivity(){
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        })
    }
    
    func OTMLogOut() {
        startAnimatingActivity()
        
        UDBClient.shared.deleteASession { (success) in
            if success {
                DispatchQueue.main.async {
                    self.stopAnimatingActivity(){
                        self.performSegue(withIdentifier: "loginSegue", sender: nil)
                    }
                }
            }
        }
    }
    
    func OTMAddPin() {
        if !(UDBClient.shared.userStudentInformation?.objectId.isEmpty)! {
            let alert=UIAlertController(title: "Are you sure you want to overwrite existing location?", message: "", preferredStyle: UIAlertControllerStyle.alert);
            
            let accept = UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) in
                self.performSegue(withIdentifier: "addPinSegue", sender: nil)
            })
            let cancel = UIAlertAction(title: "No thanks.", style: .cancel, handler: { (alertAction) in
                alert.dismiss(animated: true, completion: nil)
            })
            
            alert.addAction(accept)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "addPinSegue", sender: nil)
        }
    }
    
    func OTMRefreshPins(){
        UDBClient.shared.getStudentLocations(limit: 100, skip: 0, order: .updatedAt, completion: { (success) in
            if success {
                NotificationCenter.default.post(name: UDBClient.Constants.ReloadLocationViewsNotification, object: nil)
            } else {
                DispatchQueue.main.async {
                    let alert=UIAlertController(title: "Couldn't download student locations.", message: "", preferredStyle: .alert)
                    let accept = UIAlertAction(title: "Ok", style: .default, handler: { (alertAction) in
                        alert.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(accept)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    func OTMCancelAddingPin(){
        UDBClient.shared.tempStudentInformation = UDBStudentInformation(dictionary: [:])
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func OTMFindLocationOnTheMap(mapString: String){
        startAnimatingActivity()
        
        UDBClient.shared.tempStudentInformation?.mapString = mapString
        
        CLGeocoder().geocodeAddressString(mapString, completionHandler: { (placemarks, error) in
            if error == nil {
                UDBClient.shared.tempStudentInformation?.latitude = Float((placemarks?.first?.location?.coordinate.latitude)!)
                UDBClient.shared.tempStudentInformation?.longitude = Float((placemarks?.first?.location?.coordinate.longitude)!)
                
                DispatchQueue.main.async {
                    self.stopAnimatingActivity(){
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "postLinkViewController")
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.stopAnimatingActivity(){
                        let alert=UIAlertController(title: "Couldn't find the address.", message: "", preferredStyle: .alert)
                        let accept = UIAlertAction(title: "Ok", style: .default, handler: { (alertAction) in
                            alert.dismiss(animated: true, completion: nil)
                        })
                        alert.addAction(accept)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        })
    }
    
    func OTMSubmitStudentLocation(mediaUrl: String){
        startAnimatingActivity()
        
        fillInTempStudentName()
        UDBClient.shared.tempStudentInformation?.mediaURL = mediaUrl
        
        if (UDBClient.shared.userStudentInformation?.objectId.isEmpty)! {
            UDBClient.shared.postAStudentLocation(uniqueKey: UDBClient.shared.uniqueKey! ,studentInformation: UDBClient.shared.tempStudentInformation!, completion: { (success) in
                self.submissionResponse(worked: success)
            })
        } else {
            UDBClient.shared.putAStudentLocation(studentInformation: UDBClient.shared.tempStudentInformation!, completion: { (success) in
                self.submissionResponse(worked: success)
            })
        }
    }
    
    func fillInTempStudentName(){
        UDBClient.shared.tempStudentInformation?.firstName = UDBClient.shared.userFirstName!
        UDBClient.shared.tempStudentInformation?.lastName = UDBClient.shared.userLastName!
    }
    
    func submissionResponse(worked: Bool){
        if worked {
            DispatchQueue.main.async {
                self.stopAnimatingActivity {
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            //TODO:If the submission fails to post the data to the server, then the user should see an alert with an error message describing the failure.
            DispatchQueue.main.async {
                self.stopAnimatingActivity(){
                    let alert = UIAlertController(title: "Couldn't save student location", message: "", preferredStyle: .alert)
                    let accept = UIAlertAction(title: "Ok", style: .default, handler: { (alertAction) in
                        alert.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(accept)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func startAnimatingActivity(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "activityIndicatorViewController")
        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(controller, animated: false, completion: nil)
    }
    
    func stopAnimatingActivity(completion: (Void) -> Void){
        if (self.presentedViewController?.restorationIdentifier == "activityIndicatorViewController") {
            self.dismiss(animated: false, completion: nil)
            completion()
        }
    }
}
