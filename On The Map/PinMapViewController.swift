//
//  PinMapViewController.swift
//  On The Map
//
//  Created by Peter Khotpanya on 11/1/16.
//  Copyright © 2016 Peter Khotpanya. All rights reserved.
//
//  Pin all students to a map

import UIKit
import MapKit

class PinMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (UDBClient.shared.sessionID?.isEmpty)! {
            performSegue(withIdentifier: "loginSegue", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOut(_ sender: Any) {
        UDBClient.shared.deleteASession { (success) in
            if success {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
    }
    
    @IBAction func addPin(_ sender: Any) {
        //Check for existing user location
        
        //Ask if user wants to overwrite
    }
    
    @IBAction func refreshPin(_ sender: Any) {
        
    }
}
