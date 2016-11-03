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

class PinMapViewController: UIViewController, MKMapViewDelegate, OTMUtility {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OTMLoginChecker()
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
}
