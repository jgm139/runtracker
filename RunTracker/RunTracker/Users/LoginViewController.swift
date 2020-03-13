//
//  LoginViewController.swift
//  RunTracker
//
//  Created by Pablo López Iborra on 13/03/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var nameUser: UITextField!
    @IBOutlet weak var passwordUser: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapView)
        
        nameUser.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        passwordUser.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if self.nameUser.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            // string contains non-whitespace characters
            print(self.nameUser.text)
        }
        
        if let name = self.nameUser.text, !name.isEmpty {
            if let password = self.passwordUser.text, !password.isEmpty {
                loginButton.isEnabled = true
            } else {
                loginButton.isEnabled = false
            }
        } else {
            loginButton.isEnabled = false
        }
    }

}
