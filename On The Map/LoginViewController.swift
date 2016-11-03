//
//  LoginViewController.swift
//  On The Map
//
//  Created by Peter Khotpanya on 11/1/16.
//  Copyright © 2016 Peter Khotpanya. All rights reserved.
//
//  Allows users to identify themselves or create a new account before using the app services.

import UIKit

class LoginViewController: UIViewController, OTMUtility {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func login(_ sender: Any) {
        OTMLogin(username: emailTextField.text!, password: passwordTextField.text!)
    }

    @IBAction func signUp(_ sender: Any) {
        OTMSignUp()
    }

}
