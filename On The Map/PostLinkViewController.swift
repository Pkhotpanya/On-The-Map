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

class PostLinkViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate, OTMUtility{

    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let lat = CLLocationDegrees(Double((UDBClient.shared.tempStudentInformation?.latitude)!))
        let long = CLLocationDegrees(Double((UDBClient.shared.tempStudentInformation?.longitude)!))
        
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        // Here we create the annotation and set its coordiate, title, and subtitle properties
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
        
        configureBarButtons(enable: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        configureBarButtons(enable: false)
    }

    @IBAction func submit(_ sender: Any) {
        //TODO: If the link is empty, the app will display an alert view notifying the user.
        OTMSubmitStudentLocation(mediaUrl: linkTextField.text!)
    }
    
    func cancel(){
        OTMCancelAddingPin()
    }
    
    func configureBarButtons(enable: Bool){
        if enable{
            let cancelButton = UIBarButtonItem.init(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
            self.navigationItem.rightBarButtonItem = cancelButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        OTMSubmitStudentLocation(mediaUrl: linkTextField.text!)
        return true
    }

}
