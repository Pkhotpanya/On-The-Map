//
//  PostLinkViewController.swift
//  On The Map
//
//  Created by Peter Khotpanya on 11/1/16.
//  Copyright © 2016 Peter Khotpanya. All rights reserved.
//
//  Second and last view in the information post process.

import UIKit
import MapKit

class PostLinkViewController: UIViewController, MKMapViewDelegate, OTMUtility{

    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: Any) {
        OTMCancelAddingPin()
    }

    @IBAction func submit(_ sender: Any) {
        OTMSubmitStudentLocation()
    }

}
