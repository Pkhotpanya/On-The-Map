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
    func getAStudentLocation(uniqueKey: String, completion: @escaping (_ result: Data, _ error: NSError) -> Void){
        //where - (Parse Query) a SQL-like query allowing you to check if an object value matches some target value
        
        let url = String(format: "%@?where=%7B%22uniqueKey%22%3A%22%@%22%7D", Constants.StudentLocationURL, uniqueKey)
        
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error
                return
            }
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            completion(data!, error as! NSError)
        }
        task.resume()
    }
    
    //To get multiple student locations at one time
    func getStudentLocations(limit: Int = 100, skip: Int = 0, order: StudentLocationOrderKeys = StudentLocationOrderKeys.updatedAt, completion: @escaping (_ result: Data, _ error: NSError) -> Void){
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
                return
            }
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            completion(data!, error as! NSError)
        }
        task.resume()
    }
    
    //To create a new student location
    func postAStudentLocation(studentInformation: UDBStudentInformation, completion: @escaping (_ result: Data, _ error: NSError) -> Void){
        
        let httpBody = String(format: "{\"uniqueKey\": \"%@\", \"firstName\": \"%@\", \"lastName\": \"%@\",\"mapString\": \"%@\", \"mediaURL\": \"%@\",\"latitude\": %.6f, \"longitude\": %.6f}", studentInformation.uniqueKey, studentInformation.firstName, studentInformation.lastName, studentInformation.mapString, studentInformation.mediaURL, studentInformation.latitude, studentInformation.longitude)
        
        let request = NSMutableURLRequest(url: NSURL(string: Constants.StudentLocationURL)! as URL)
        request.httpMethod = "POST"
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody.data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            completion(data!, error as! NSError)
        }
        task.resume()
    }
    
    //To update an existing student location
    func putAStudentLocation(studentInformation: UDBStudentInformation, completion: @escaping (_ result: Data, _ error: NSError) -> Void){

        //objectId - (String) the object ID of the StudentLocation to update; specify the object ID right after StudentLocation in URL as seen below

        let url = String(format: "%@/%@", Constants.StudentLocationURL, studentInformation.objectId)
        
        let httpBody = String(format: "{\"uniqueKey\": \"%@\", \"firstName\": \"%@\", \"lastName\": \"%@\",\"mapString\": \"%@\", \"mediaURL\": \"%@\",\"latitude\": %.6f, \"longitude\": %.6f}", studentInformation.uniqueKey, studentInformation.firstName, studentInformation.lastName, studentInformation.mapString, studentInformation.mediaURL, studentInformation.latitude, studentInformation.longitude)
        
        let request = NSMutableURLRequest(url: NSURL(string:url)! as URL)
        request.httpMethod = "PUT"
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody.data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            completion(data!, error as! NSError)
        }
        task.resume()
    }
    
}
