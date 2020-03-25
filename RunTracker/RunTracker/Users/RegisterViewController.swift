//
//  RegisterViewController.swift
//  RunTracker
//
//  Created by Pablo López Iborra on 13/03/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreData

class RegisterViewController: UIViewController {

    @IBOutlet weak var nameUser: UITextField!
    @IBOutlet weak var passwordUser: UITextField!
    @IBOutlet weak var repeatPasswordUser: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    var register = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapView)
        
        nameUser.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        passwordUser.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        repeatPasswordUser.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
    }
    
    @objc func dismissKeyboard() {
       view.endEditing(true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let name = self.nameUser.text, !name.isEmpty {
            if let password = self.passwordUser.text, !password.isEmpty {
                if let newPassword = self.passwordUser.text, !newPassword.isEmpty {
                    registerButton.isEnabled = true
                } else {
                    registerButton.isEnabled = false
                }
            } else {
                registerButton.isEnabled = false
            }
        } else {
            registerButton.isEnabled = false
        }
    }

    func registerAction() {
        guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let miContexto = miDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<User>(entityName: "User")
        let users = try? miContexto.fetch(request)
        
        var exist = false
        
        for data in users!{
            if data.username == self.nameUser.text {
                exist = true
            }
        }
        
        if exist == false {
            if self.passwordUser.text == self.repeatPasswordUser.text {
                let user = User(context: miContexto)
                user.username = self.nameUser.text
                user.password = self.passwordUser.text
                user.image = UIImage(named: "profilePhoto")?.pngData()
                do {
                    try miContexto.save()
                    self.register = true
                    UserSingleton.userSingleton.user = user
                } catch {
                   print("Error al guardar el contexto: \(error)")
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "Las contraseñas no coinciden", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Cerrar", style: UIAlertAction.Style.destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                self.register = false
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "El nombre de usuario ya existe", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: UIAlertAction.Style.destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            self.register = false
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let ident = identifier {
            if ident == "register" {
                self.registerAction()
                if self.register == true {
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
