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

        let lat = CLLocationDegrees(Double((OTMModel.shared.tempStudentInformation?.latitude)!))
        let long = CLLocationDegrees(Double((OTMModel.shared.tempStudentInformation?.longitude)!))
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
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
        if (linkTextField.text?.isEmpty)! {
            let alert = UIAlertController(title: "Link can't be blank", message: "", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: { (alertAction) in
                alert.dismiss(animated: true, completion: nil)
            })
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        } else {
            OTMSubmitStudentLocation(mediaUrl: linkTextField.text!)
        }
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
    
    // MARK: MKMapViewDelegate
    
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
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        OTMSubmitStudentLocation(mediaUrl: linkTextField.text!)
        return true
    }

}
