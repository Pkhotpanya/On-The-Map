//
//  LoginViewController.swift
//  On The Map
//
//  Created by Peter Khotpanya on 11/1/16.
//  Copyright © 2016 Peter Khotpanya. All rights reserved.
//
//  Allows users to identify themselves or create a new account before using the app services.

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func login(_ sender: Any) {
        UDBClient.shared.postASession(username: emailTextField.text!, password: passwordTextField.text!, completion: { (success) in
            if !success {
                let alert=UIAlertController(title: "Failed to login", message: "", preferredStyle: UIAlertControllerStyle.alert);
                //show it
                self.show(alert, sender: self);
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }

    @IBAction func signUp(_ sender: Any) {
        UIApplication.shared.open(NSURL(string: "https://www.udacity.com/account/auth#!/signup") as! URL, options:[:], completionHandler: nil)
    }

}
