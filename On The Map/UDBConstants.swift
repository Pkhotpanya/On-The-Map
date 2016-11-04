//
//  UDBConstants.swift
//  On The Map
//
//  Created by Peter Khotpanya on 11/1/16.
//  Copyright © 2016 Peter Khotpanya. All rights reserved.
//
//  Placeholder for commonly used words on Udacity's web services.

import UIKit

extension UDBClient {

    struct Constants {
        static let ParseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RESTAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        static let StudentLocationURL = "https://parse.udacity.com/parse/classes/StudentLocation"
        static let SessionURL = "https://www.udacity.com/api/session"
        static let PublicUserDataURL = "https://www.udacity.com/api/users"
        
        static let ReloadLocationViewsNotification = NSNotification.Name(rawValue: "ReloadPinViewsNotification")
    }
    
    enum StudentLocationOrderKeys: String {
        case updatedAt
        case reverseUpdatedAt = "-updatedAt"
    }

}
