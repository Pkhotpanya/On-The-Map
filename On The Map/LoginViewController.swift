//
//  LoginViewController.swift
//  On The Map
//
//  Created by Peter Khotpanya on 11/1/16.
//  Copyright © 2016 Peter Khotpanya. All rights reserved.
//
//  Allows users to identify themselves or create a new account before using the app services.

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, OTMUtility {
    
    @IBOutlet weak var welcomeStackView: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func login(_ sender: Any) {
        OTMLogin(username: emailTextField.text!, password: passwordTextField.text!)
    }

    @IBAction func signUp(_ sender: Any) {
        OTMSignUp()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailTextField.isFirstResponder {
            passwordTextField.becomeFirstResponder()
        } else if passwordTextField.isFirstResponder {
            textField.resignFirstResponder()
            OTMLogin(username: emailTextField.text!, password: passwordTextField.text!)
        }
        return true
    }
    
    // MARK: Keyboard helper functions
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func keyboardWillShow(_ notification: NSNotification) {
        shouldFocusOnTextfields()
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        welcomeStackView.isHidden = false
    }
    
    func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func orientationChanged(_ notification: NSNotification){
        shouldFocusOnTextfields()
    }
    
    func keyboardIsVisible() -> Bool{
        return (emailTextField.isFirstResponder || passwordTextField.isFirstResponder)
    }
    
    func shouldFocusOnTextfields(){
        if UIApplication.shared.statusBarOrientation.isPortrait && keyboardIsVisible(){
            welcomeStackView.isHidden = true
        } else {
            welcomeStackView.isHidden = false
        }
    }
    
}
