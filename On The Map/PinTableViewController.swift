//
//  PinTableViewController.swift
//  On The Map
//
//  Created by Peter Khotpanya on 11/1/16.
//  Copyright © 2016 Peter Khotpanya. All rights reserved.
//
//  List all students.

import UIKit

class PinTableViewController: UITableViewController, OTMUtility {

    var studentLocations = [UDBStudentInformation]()
    var shouldReload: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PinTableViewController.flipOnShouldReload), name: UDBClient.Constants.ReloadLocationViewsNotification, object: nil)
        
        //Initial loading of table values from shared model.
        studentLocations = UDBClient.shared.studentsLocations
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldReload {
            reloadTable()
            shouldReload = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func logOut(_ sender: Any) {
        OTMLogOut()
    }
    
    @IBAction func addPin(_ sender: Any) {
        OTMAddPin()
    }
    
    @IBAction func refreshPin(_ sender: Any) {
        OTMRefreshPins()
    }
    
    func flipOnShouldReload(){
        if self.isViewLoaded && (self.view.window != nil){
            DispatchQueue.main.async {
                self.reloadTable()
            }
        } else {
            shouldReload = true
        }
    }
    
    func reloadTable(){
        studentLocations = UDBClient.shared.studentsLocations
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocations.count//UDBClient.shared.studentsLocations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicTableCell", for: indexPath)
        
        let studentInformation = studentLocations[indexPath.item]
        cell.imageView?.image = UIImage(named: "pin")
        cell.textLabel?.text = String(format: "%@ %@", studentInformation.firstName, studentInformation.lastName)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentInformation = studentLocations[indexPath.item]
        if !studentInformation.mediaURL.isEmpty {
            UIApplication.shared.open(NSURL(string: studentInformation.mediaURL) as! URL, options:[:], completionHandler: nil)
        }
    }

}
