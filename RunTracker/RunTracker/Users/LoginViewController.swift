//
//  LoginViewController.swift
//  RunTracker
//
//  Created by Pablo López Iborra on 13/03/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {

    @IBOutlet weak var nameUser: UITextField!
    @IBOutlet weak var passwordUser: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var login = false
    
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

    func loginAction() {
        guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let miContexto = miDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<User>(entityName: "User")
        let users = try? miContexto.fetch(request)
        
        var exist = false
        var password: String = ""
        
        for data in users!{
            if data.username == self.nameUser.text {
                UserSingleton.userSingleton.user = data
                password = data.password!
                exist = true
            }
        }
        
        if exist == false || self.passwordUser.text != password {
            let alert = UIAlertController(title: "Error", message: "Combinación incorrecta", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: UIAlertAction.Style.destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.login = false
        } else if self.passwordUser.text == password {
            self.login = true
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let ident = identifier {
            if ident == "login" {
                self.loginAction()
                if self.login == true {
                    self.initSession()
                    return true
                }
            }
        }
        return false
    }
    
    func initSession(){
        guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let miContexto = miDelegate.persistentContainer.viewContext
        
        let request : NSFetchRequest<Session> = NSFetchRequest(entityName:"Session")
        let session = try? miContexto.fetch(request)
        
        if session!.count > 0 {
            session![0].username = UserSingleton.userSingleton.user.username
        } else {
            let session = Session(context: miContexto)
            session.username = UserSingleton.userSingleton.user.username
        }
        do {
            try miContexto.save()
        } catch {
           print("Error al guardar el contexto: \(error)")
        }
    }
}
