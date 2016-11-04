//
//  UDBClient.swift
//  On The Map
//
//  Created by Peter Khotpanya on 11/1/16.
//  Copyright © 2016 Peter Khotpanya. All rights reserved.
//
//  Handle login, authorization, and authentication to Udacity's database.

import UIKit

class UDBClient: NSObject {
    
    static let shared = UDBClient()
    
    // authentication state
    var sessionID: String? = ""
    var uniqueKey: String? = ""
    var userFirstName: String? = ""
    var userLastName: String? = ""
    
    // on device cache
    var studentInformation: UDBStudentInformation? = UDBStudentInformation(dictionary: [:])
    var studentsLocations = [UDBStudentInformation]()
    
    // MARK: Initializers
    private override init() {
        super.init()
    }

    //To authenticate Udacity API requests, you need to get a session ID.
    func postASession(username: String, password: String, completion: @escaping (_ success: Bool) -> Void){
        //udacity - (Dictionary) a dictionary containing a username/password pair used for authentication
        //username - (String) the username (email) for a Udacity student
        //password - (String) the password for a Udacity student
        
        let httpBody = String(format:"{\"udacity\": {\"username\": \"%@\", \"password\": \"%@\"}}", username, password)
        
        let request = NSMutableURLRequest(url: NSURL(string: Constants.SessionURL)! as URL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody.data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                completion(false)
                return
            }
            let newData = data?.subdata(in: 5..<data!.count) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            
            do{
                // Convert NSData to Dictionary where keys are of type String, and values are of any type
                let json = try JSONSerialization.jsonObject(with: newData!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                    
                if let account = json["account"] as! [String:AnyObject]?{
                    self.uniqueKey = account["key"] as? String
                }
                
                if let sessionValue = json["session"] as! [String:AnyObject]?{
                    self.sessionID = sessionValue["id"] as? String
                }
                
                DispatchQueue.global(qos: .userInitiated).async {
                    self.getPublicUserData(uniqueKey: self.uniqueKey!)
                }
                
            } catch {
                
            }
            
            completion(true)
        }
        task.resume()
    }
    
    //Once you get a session ID using Udacity's API, you should delete the session ID to "logout".
    func deleteASession(completion: @escaping (_ success: Bool) -> Void){

        let request = NSMutableURLRequest(url: NSURL(string: Constants.SessionURL)! as URL)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                completion(false)
                return
            }
            let newData = data?.subdata(in: 5..<data!.count) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            
            self.sessionID = ""
            self.uniqueKey = ""
            self.userFirstName = ""
            self.userLastName = ""
            self.studentInformation = UDBStudentInformation(dictionary: [:])
            
            completion(true)
        }
        task.resume()
    }
    
    //The whole purpose of using Udacity's API is to retrieve some basic user information before posting data to Parse.
    func getPublicUserData(uniqueKey: String){
        let url = String(format: "%@/%@", Constants.PublicUserDataURL, uniqueKey)
    
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let newData = data?.subdata(in: 5..<data!.count) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            
            do{
                // Convert NSData to Dictionary where keys are of type String, and values are of any type
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                
                if let student = json["user"] as! [String:AnyObject]?{
                    self.userFirstName = student["first_name"] as! String?
                    self.userLastName = student["last_name"] as! String?
                }
            } catch {
                
            }
        }
        task.resume()
    }
    
}
