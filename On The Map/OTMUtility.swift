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
        
        UDBClient.shared.postASession(username: username, password: password, completion: { (results, success, errorMessage) in
            if !success {
                //If the login does not succeed, the user will be presented with an alert view specifying whether it was a failed network connection, or an incorrect email and password.
                DispatchQueue.main.async {
                    self.stopAnimatingActivity(){
                        self.presentAlertMessage(title: "Failed to login.", message: errorMessage)
                    }
                }
            } else {
                if let account = results["account"] as! [String:AnyObject]?{
                    OTMModel.shared.uniqueKey = account["key"] as? String
                }
                
                DispatchQueue.global(qos: .userInitiated).async {
                    UDBClient.shared.getPublicUserData(uniqueKey: OTMModel.shared.uniqueKey!, completion:{(results, success, errorMessage) in
                        if success {
                            if let student = results["user"] as! [String:AnyObject]?{
                                OTMModel.shared.userFirstName = student["first_name"] as! String?
                                OTMModel.shared.userLastName = student["last_name"] as! String?
                            }
                        } else {
                            self.presentAlertMessage(title: "Couldn't get user's public data.", message: errorMessage)
                        }
                        
                    })
                    UDBClient.shared.getAStudentLocation(uniqueKey: OTMModel.shared.uniqueKey!, completion:{(results, success, errorMessage) in
                        if let students = results["results"] as! [[String:AnyObject]]?{
                            if success {
                                if let studentInfo = students.first {
                                    OTMModel.shared.userStudentInformation = UDBStudentInformation(dictionary: studentInfo)
                                } else if students.isEmpty {
                                    OTMModel.shared.userStudentInformation = UDBStudentInformation(dictionary: [:])
                                }
                            } else {
                                self.presentAlertMessage(title: "Couldn't get student's location.", message: errorMessage)
                            }
                            
                        }
                    })
                }
                
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
                        
                        self.clearUserInfo()
                        
                        self.performSegue(withIdentifier: "loginSegue", sender: nil)
                    }
                }
            }
        }
    }
    
    func OTMAddPin() {
        if !(OTMModel.shared.userStudentInformation?.objectId.isEmpty)! {
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
        UDBClient.shared.getStudentLocations(limit: 100, skip: 0, order: .reverseUpdatedAt, completion: { (results, success, errorMessage) in
            if success {
                if let students = results["results"] as! [[String:AnyObject]]?{
                    var tempStudentsInformation = [UDBStudentInformation]()
                    for studentInfo in students{
                        tempStudentsInformation.append( UDBStudentInformation(dictionary: studentInfo) )
                    }
                    OTMModel.shared.studentsLocations.removeAll()
                    OTMModel.shared.studentsLocations.append(contentsOf: tempStudentsInformation)
                }

                NotificationCenter.default.post(name: UDBClient.Constants.ReloadLocationViewsNotification, object: nil)
            } else {
                DispatchQueue.main.async {
                    self.presentAlertMessage(title: "Couldn't download student locations.", message: "")
                }
            }
        })
    }
    
    func OTMCancelAddingPin(){
        OTMModel.shared.tempStudentInformation = UDBStudentInformation(dictionary: [:])
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func OTMFindLocationOnTheMap(mapString: String){
        startAnimatingActivity()
        
        OTMModel.shared.tempStudentInformation?.mapString = mapString
        
        CLGeocoder().geocodeAddressString(mapString, completionHandler: { (placemarks, error) in
            if error == nil {
                OTMModel.shared.tempStudentInformation?.latitude = Float((placemarks?.first?.location?.coordinate.latitude)!)
                OTMModel.shared.tempStudentInformation?.longitude = Float((placemarks?.first?.location?.coordinate.longitude)!)
                
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
                        self.presentAlertMessage(title: "Couldn't find the address.", message: "")
                    }
                }
            }
        })
    }
    
    func OTMSubmitStudentLocation(mediaUrl: String){
        startAnimatingActivity()
        
        fillInTempStudentName()
        OTMModel.shared.tempStudentInformation?.mediaURL = mediaUrl
        
        if (OTMModel.shared.userStudentInformation?.objectId.isEmpty)! {
            UDBClient.shared.postAStudentLocation(uniqueKey: OTMModel.shared.uniqueKey!, studentInformation: OTMModel.shared.tempStudentInformation!, completion: { (results, success, errorMessage) in
                
                if let objectId = results["objectId"]{
                    OTMModel.shared.objectId = objectId as? String
                }
                
                DispatchQueue.global(qos: .userInitiated).async {
                    UDBClient.shared.getAStudentLocation(uniqueKey: OTMModel.shared.uniqueKey!, completion:{(results, success, errorMessage) in
                        if let students = results["results"] as! [[String:AnyObject]]?{
                            if success {
                                if let studentInfo = students.first {
                                    OTMModel.shared.userStudentInformation = UDBStudentInformation(dictionary: studentInfo)
                                } else if students.isEmpty {
                                    OTMModel.shared.userStudentInformation = UDBStudentInformation(dictionary: [:])
                                }
                            } else {
                                self.presentAlertMessage(title: "Couldn't get student's location.", message: errorMessage)
                            }
                            
                        }
                    })
                }
                OTMModel.shared.tempStudentInformation = UDBStudentInformation(dictionary: [:])
                
                self.studentInformationsubmissionResponse(worked: success, why: errorMessage)
            })
        } else {
            UDBClient.shared.putAStudentLocation(objectId: (OTMModel.shared.userStudentInformation?.objectId)!, uniqueKey: OTMModel.shared.uniqueKey!, studentInformation: OTMModel.shared.tempStudentInformation!, completion: { (results, success, errorMessage) in
                
                OTMModel.shared.userStudentInformation = OTMModel.shared.tempStudentInformation
                OTMModel.shared.tempStudentInformation = UDBStudentInformation(dictionary: [:])
                
                self.studentInformationsubmissionResponse(worked: success, why: errorMessage)
            })
        }
    }
    
    //MARK: Submit student location helper functions
    
    func fillInTempStudentName(){
        OTMModel.shared.tempStudentInformation?.firstName = OTMModel.shared.userFirstName!
        OTMModel.shared.tempStudentInformation?.lastName = OTMModel.shared.userLastName!
    }
    
    func studentInformationsubmissionResponse(worked: Bool, why: String){
        if worked {
            DispatchQueue.main.async {
                self.stopAnimatingActivity {
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            //If the submission fails to post the data to the server, then the user should see an alert with an error message describing the failure.
            DispatchQueue.main.async {
                self.stopAnimatingActivity(){
                    self.presentAlertMessage(title: "Couldn't save student location.", message: why)
                }
            }
        }
    }
    
    //MARK: Log out helper function
    func clearUserInfo(){
        OTMModel.shared.uniqueKey = ""
        OTMModel.shared.userFirstName = ""
        OTMModel.shared.userLastName = ""
        OTMModel.shared.tempStudentInformation = UDBStudentInformation(dictionary: [:])
        OTMModel.shared.userStudentInformation = UDBStudentInformation(dictionary: [:])
    }
    
    //MARK: Alert message helper function
    func presentAlertMessage(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let accept = UIAlertAction(title: "Ok", style: .default, handler: { (alertAction) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(accept)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: Activity indicator modal popup functions
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
