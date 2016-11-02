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
    
    // authentication state
    var sessionID: String? = nil
    var userID: Int? = nil
    
    // MARK: Shared Instance
    class func sharedInstance() -> UDBClient {
        struct Singleton {
            static var shared = UDBClient()
        }
        return Singleton.shared
    }

    //To authenticate Udacity API requests, you need to get a session ID.
    func postASession(username: String, password: String, completion: @escaping (_ result: Data, _ error: NSError) -> Void){

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
                return
            }
            let newData = data?.subdata(in: 5..<data!.count) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            completion(data!, error as! NSError)
        }
        task.resume()
    }
    
    //Once you get a session ID using Udacity's API, you should delete the session ID to "logout".
    func deleteASession(completion: @escaping (_ result: Data, _ error: NSError) -> Void){

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
                return
            }
            let newData = data?.subdata(in: 5..<data!.count) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            completion(data!, error as! NSError)
        }
        task.resume()
    }
    
    //The whole purpose of using Udacity's API is to retrieve some basic user information before posting data to Parse.
    func getPublicUserData(userId: String, completion: @escaping (_ result: Data, _ error: NSError) -> Void){
        
        let url = String(format: "%@/%@", Constants.PublicUserDataURL, userId)
    
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let newData = data?.subdata(in: 5..<data!.count) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            completion(data!, error as! NSError)
        }
        task.resume()
    }
    
}
