//
//  UDBServices.swift
//  On The Map
//
//  Created by Peter Khotpanya on 11/1/16.
//  Copyright © 2016 Peter Khotpanya. All rights reserved.
//
//  Handle requests for web services from Udacity web APIs including login, authorization, and authentication to Udacity's database.

import UIKit

extension UDBClient {
    
    //To authenticate Udacity API requests, you need to get a session ID.
    func postASession(username: String, password: String, completion: @escaping (_ results: Dictionary<String, AnyObject>, _ success: Bool, _ errorMessage: String) -> Void){
        //udacity - (Dictionary) a dictionary containing a username/password pair used for authentication
        //username - (String) the username (email) for a Udacity student
        //password - (String) the password for a Udacity student
        
        let httpBody = String(format:"{\"udacity\": {\"username\": \"%@\", \"password\": \"%@\"}}", username, password)
        
        var request = URLRequest(url: NSURL(string: Constants.SessionURL)! as URL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody.data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { 
                completion([:], false, error?.localizedDescription ?? "")
                return
            }
            let newData = data?.subdata(in: 5..<data!.count)
            
            do{
                let json = try JSONSerialization.jsonObject(with: newData!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                
                if let errorStatus = json["status"] {
                    if errorStatus as! Int == 400 {
                        let errorMsg = String(format: "Missing %@", (json["parameter"]?.substring(from:8))!)
                        completion([:], false, errorMsg)
                    }
                    if errorStatus as! Int == 403 {
                        completion([:], false, "Account not found or incorrect password")
                    }
                }
                
                if let sessionValue = json["session"] as! [String:AnyObject]?{
                    self.sessionID = sessionValue["id"] as? String
                }
                
                if let errorMessage = error?.localizedDescription {
                    completion(json, true, errorMessage)
                } else {
                    completion(json, true, "")
                }
                
            } catch {
                
            }
    
        }
        task.resume()
    }
    
    //Once you get a session ID using Udacity's API, you should delete the session ID to "logout".
    func deleteASession(completion: @escaping (_ success: Bool) -> Void){
        
        var request = URLRequest(url: NSURL(string: Constants.SessionURL)! as URL)
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
            if error != nil {
                completion(false)
                return
            }

            self.sessionID = ""
            
            completion(true)
        }
        task.resume()
    }
    
    //The whole purpose of using Udacity's API is to retrieve some basic user information before posting data to Parse.
    func getPublicUserData(uniqueKey: String, completion: @escaping (_ results: Dictionary<String, AnyObject>, _ success: Bool, _ errorMessage: String) -> Void){
        let url = String(format: "%@/%@", Constants.PublicUserDataURL, uniqueKey)
        
        let request = URLRequest(url: NSURL(string: url)! as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                completion([:], false, error?.localizedDescription ?? "")
                return
            }
            let newData = data?.subdata(in: 5..<data!.count)
            
            do{
                let json = try JSONSerialization.jsonObject(with: newData!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                
                if let errorStatus = json["status"] {
                    if errorStatus as! Int == 404 {
                        completion([:], false, "Account not found")
                    }
                }
                
                completion(json, true, "")
            } catch {
                
            }
        }
        task.resume()
    }
    
    //To get a single student location
    func getAStudentLocation(uniqueKey: String, completion: @escaping (_ results:Dictionary<String, AnyObject>, _ success: Bool, _ errorMessage: String) -> Void){
        //where - (Parse Query) a SQL-like query allowing you to check if an object value matches some target value
        
        let stringUrl = String(format: "%@?where={\"uniqueKey\":\"%@\"}", Constants.StudentLocationURL, uniqueKey)
        let urlWithEncoding = stringUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var request = URLRequest(url: NSURL(string: urlWithEncoding!)! as URL)
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                completion([:], false, error?.localizedDescription ?? "")
                return
            }
            
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                
                if let errorStatus = json["status"] as? Int {
                    if errorStatus >= 400 && errorStatus <= 499 {
                        completion([:], false, "Couldn't get student location. ")
                    }
                }
                
                completion(json, true, "")
            } catch {
                
            }
        }
        task.resume()

    }
    
    //To get multiple student locations at one time
    func getStudentLocations(limit: Int = 100, skip: Int = 0, order: StudentLocationOrderKeys = StudentLocationOrderKeys.updatedAt, completion: @escaping (_ results: Dictionary<String, AnyObject>, _ success: Bool, _ errorMessage: String) -> Void){
        //limit - (Number) specifies the maximum number of StudentLocation objects to return in the JSON response
        //skip - (Number) use this parameter with limit to paginate through results
        //order - (String) a comma-separate list of key names that specify the sorted order of the results. Prefixing a key name with a negative sign reverses the order (default order is ascending)

        let url = String(format: "%@?limit=%@&skip=%@&order=%@", Constants.StudentLocationURL, String(limit), String(skip), order.rawValue)
        var request = URLRequest(url: NSURL(string: url)! as URL)
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                completion([:], false, error?.localizedDescription ?? "")
                return
            }
            
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                
                if let errorStatus = json["status"] as? Int {
                    if errorStatus >= 400 && errorStatus <= 499 {
                        completion([:], false, "Couldn't get student locations. ")
                    }
                }
                
                completion(json, true, "")
            } catch {
                
            }
            
        }
        task.resume()
    }
    
    //To create a new student location
    func postAStudentLocation(uniqueKey: String, studentInformation: UDBStudentInformation, completion: @escaping (_ results: Dictionary<String, AnyObject>,_ success: Bool,_ errorMessage: String) -> Void){
        
        let httpBody = String(format: "{\"uniqueKey\": \"%@\", \"firstName\": \"%@\", \"lastName\": \"%@\",\"mapString\": \"%@\", \"mediaURL\": \"%@\",\"latitude\": %.6f, \"longitude\": %.6f}", uniqueKey, studentInformation.firstName, studentInformation.lastName, studentInformation.mapString, studentInformation.mediaURL, studentInformation.latitude, studentInformation.longitude)
        
        var request = URLRequest(url: NSURL(string: Constants.StudentLocationURL)! as URL)
        request.httpMethod = "POST"
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody.data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                completion([:], false, error?.localizedDescription ?? "")
                return
            }
            
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                
                completion(json, true, error?.localizedDescription ?? "")
            } catch {
                
            }
        }
        task.resume()
    }
    
    //To update an existing student location
    func putAStudentLocation(objectId: String, uniqueKey: String, studentInformation: UDBStudentInformation, completion: @escaping (_ results: Dictionary<String, AnyObject>, _ success: Bool,_ errorMessage: String) -> Void){
        //objectId - (String) the object ID of the StudentLocation to update; specify the object ID right after StudentLocation in URL as seen below

        let url = String(format: "%@/%@", Constants.StudentLocationURL, objectId)
        
        let httpBody = String(format: "{\"uniqueKey\": \"%@\", \"firstName\": \"%@\", \"lastName\": \"%@\",\"mapString\": \"%@\", \"mediaURL\": \"%@\",\"latitude\": %.6f, \"longitude\": %.6f}", uniqueKey, studentInformation.firstName, studentInformation.lastName, studentInformation.mapString, studentInformation.mediaURL, studentInformation.latitude, studentInformation.longitude)
        
        var request = URLRequest(url: NSURL(string:url)! as URL)
        request.httpMethod = "PUT"
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody.data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                completion([:], false, error?.localizedDescription ?? "")
                return
            }
            
            completion([:], true, error?.localizedDescription ?? "")
        }
        task.resume()
    }
    
}
