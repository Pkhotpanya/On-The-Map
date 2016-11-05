//
//  UDBServices.swift
//  On The Map
//
//  Created by Peter Khotpanya on 11/1/16.
//  Copyright © 2016 Peter Khotpanya. All rights reserved.
//
//  Handle requests for web services from Udacity web APIs

import UIKit

extension UDBClient {
    
    //To get a single student location
    func getAStudentLocation(uniqueKey: String){
        //where - (Parse Query) a SQL-like query allowing you to check if an object value matches some target value
        
        let stringUrl = String(format: "%@?where={\"uniqueKey\":\"%@\"}", Constants.StudentLocationURL, uniqueKey)
        let urlWithEncoding = stringUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let request = NSMutableURLRequest(url: NSURL(string: urlWithEncoding!)! as URL)
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error
                return
            }
            //print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            
            do{
                // Convert NSData to Dictionary where keys are of type String, and values are of any type
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                
                if let students = json["results"] as! [[String:AnyObject]]?{
                    if let studentInfo = students.first {
                        self.userStudentInformation = UDBStudentInformation(dictionary: studentInfo)
                    }
                }
                
            } catch {
                
            }
        }
        task.resume()

    }
    
    //To get multiple student locations at one time
    func getStudentLocations(limit: Int = 100, skip: Int = 0, order: StudentLocationOrderKeys = StudentLocationOrderKeys.updatedAt, completion: @escaping (_ success: Bool) -> Void){
        //limit - (Number) specifies the maximum number of StudentLocation objects to return in the JSON response
        //skip - (Number) use this parameter with limit to paginate through results
        //order - (String) a comma-separate list of key names that specify the sorted order of the results. Prefixing a key name with a negative sign reverses the order (default order is ascending)

        //Form the URL
        let url = String(format: "%@?limit=%@&skip=%@&order=%@", Constants.StudentLocationURL, String(limit), String(skip), order.rawValue)
        
        //Form the request
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                completion(false)
                return
            }
            //print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            
            do{
                // Convert NSData to Dictionary where keys are of type String, and values are of any type
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                
                if let students = json["results"] as! [[String:AnyObject]]?{
                    var tempStudentsInformation = [UDBStudentInformation]()
                    for studentInfo in students{
                        tempStudentsInformation.append( UDBStudentInformation(dictionary: studentInfo) )
                    }
                    self.studentsLocations.removeAll()
                    self.studentsLocations.append(contentsOf: tempStudentsInformation)
                }
                
            } catch {
                
            }
            
            completion(true)
        }
        task.resume()
    }
    
    //To create a new student location
    func postAStudentLocation(uniqueKey: String, studentInformation: UDBStudentInformation, completion: @escaping (_ success: Bool,_ errorMessage: String) -> Void){
        
        let httpBody = String(format: "{\"uniqueKey\": \"%@\", \"firstName\": \"%@\", \"lastName\": \"%@\",\"mapString\": \"%@\", \"mediaURL\": \"%@\",\"latitude\": %.6f, \"longitude\": %.6f}", uniqueKey, studentInformation.firstName, studentInformation.lastName, studentInformation.mapString, studentInformation.mediaURL, studentInformation.latitude, studentInformation.longitude)
        
        let request = NSMutableURLRequest(url: NSURL(string: Constants.StudentLocationURL)! as URL)
        request.httpMethod = "POST"
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody.data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                completion(false, (error?.localizedDescription)!)
                return
            }
            //print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            
            do{
                // Convert NSData to Dictionary where keys are of type String, and values are of any type
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                
                if let objectId = json["objectId"]{
                    self.objectId = objectId as? String
                }
            } catch {
                
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.getAStudentLocation(uniqueKey: self.uniqueKey!)
            }
            self.tempStudentInformation = UDBStudentInformation(dictionary: [:])
            if let errorMessage = error?.localizedDescription {
                completion(true, errorMessage)
            } else {
                completion(true, "")
            }
        }
        task.resume()
    }
    
    //To update an existing student location
    func putAStudentLocation(objectId: String, uniqueKey: String, studentInformation: UDBStudentInformation, completion: @escaping (_ success: Bool,_ errorMessage: String) -> Void){
        //objectId - (String) the object ID of the StudentLocation to update; specify the object ID right after StudentLocation in URL as seen below

        let url = String(format: "%@/%@", Constants.StudentLocationURL, objectId)
        
        let httpBody = String(format: "{\"uniqueKey\": \"%@\", \"firstName\": \"%@\", \"lastName\": \"%@\",\"mapString\": \"%@\", \"mediaURL\": \"%@\",\"latitude\": %.6f, \"longitude\": %.6f}", uniqueKey, studentInformation.firstName, studentInformation.lastName, studentInformation.mapString, studentInformation.mediaURL, studentInformation.latitude, studentInformation.longitude)
        
        let request = NSMutableURLRequest(url: NSURL(string:url)! as URL)
        request.httpMethod = "PUT"
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody.data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                completion(false, (error?.localizedDescription)!)
                return
            }
            //print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            
            self.userStudentInformation = studentInformation
            self.tempStudentInformation = UDBStudentInformation(dictionary: [:])
    
            if let errorMessage = error?.localizedDescription {
                completion(true, errorMessage)
            } else {
                completion(true, "")
            }
        }
        task.resume()
    }
    
}
