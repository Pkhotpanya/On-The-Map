//
//  PostLocationViewController.swift
//  On The Map
//
//  Created by Peter Khotpanya on 11/1/16.
//  Copyright © 2016 Peter Khotpanya. All rights reserved.
//
// First view in the information post process.

import UIKit

class PostLocationViewController: UIViewController, OTMUtility {
    
    @IBOutlet weak var locationTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancel(_ sender: Any) {
        OTMCancelAddingPin()
    }
    
    @IBAction func findLocationOnTheMap(_ sender: Any) {
        OTMFindLocationOnTheMap()
    }

}

