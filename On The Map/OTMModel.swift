//
//  OTMModel.swift
//  On The Map
//
//  Created by Peter Khotpanya on 11/6/16.
//  Copyright © 2016 Peter Khotpanya. All rights reserved.
//
//  Shared data model

import UIKit

class OTMModel: NSObject {

    static let shared = OTMModel()
    
    // MARK: Initializers
    private override init() {
        super.init()
    }
    
    // MARK: Current user info
    var uniqueKey: String? = ""
    var userFirstName: String? = ""
    var userLastName: String? = ""
    var objectId: String? = ""
    var userStudentInformation: UDBStudentInformation? = UDBStudentInformation(dictionary: [:])
    
    // MARK: Student locations and student information placeholder
    var tempStudentInformation: UDBStudentInformation? = UDBStudentInformation(dictionary: [:])
    var studentsLocations = [UDBStudentInformation]()
    
}
