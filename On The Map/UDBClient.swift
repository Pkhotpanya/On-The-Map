//
//  UDBClient.swift
//  On The Map
//
//  Created by Peter Khotpanya on 11/1/16.
//  Copyright © 2016 Peter Khotpanya. All rights reserved.
//
//  Shared client for using Udacity's web APIs

import UIKit

class UDBClient: NSObject {
    
    static let shared = UDBClient()
    
    // MARK: Initializers
    private override init() {
        super.init()
    }
    
    // MARK: Authentication state
    var sessionID: String? = ""

}
