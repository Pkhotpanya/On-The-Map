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
    var annotations = [MKPointAnnotation]()
    var shouldReload: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PinMapViewController.flipOnShouldReload), name: UDBClient.Constants.ReloadLocationViewsNotification, object: nil)
        
        //Initial call for getting the students location over the web.
        OTMRefreshPins()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldReload {
            reloadMap()
            shouldReload = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Inital call to check for login
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
    
    func flipOnShouldReload(){
        if self.isViewLoaded && (self.view.window != nil) {
            DispatchQueue.main.async {
                self.reloadMap()
            }
        } else {
            shouldReload = true
        }
    }
    
    func reloadMap(){
        mapView.removeAnnotations(annotations)
        
        updateMapAnnotation()
        
        mapView.addAnnotations(annotations)
    }
    
    func updateMapAnnotation(){
        //Synchronize
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        annotations.removeAll()
        
        let locations = UDBClient.shared.studentsLocations
        
        for studentLocation in locations {
            
            let lat = CLLocationDegrees(studentLocation.latitude)
            let long = CLLocationDegrees(studentLocation.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = studentLocation.firstName
            let last = studentLocation.lastName
            let mediaURL = studentLocation.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            pinView!.canShowCallout = true
            pinView!.calloutOffset = CGPoint(x: -5, y: 5)
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle! {
                if !toOpen.isEmpty {
                    UIApplication.shared.open(NSURL(string: toOpen) as! URL, options:[:], completionHandler: nil)
                }
            }
        }
    }
}
