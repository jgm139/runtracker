//
//  ProfileViewController.swift
//  RunTracker
//
//  Created by Julia García Martínez on 17/02/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var height: UITextField!
    
    @IBOutlet weak var sexImage: UIImageView!
    
    var textChange: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        name.addTarget(self, action: #selector(textFieldDidEndEditing), for: UIControl.Event.editingDidEnd)
        name.addTarget(self, action: #selector(textFieldDidBegin), for: UIControl.Event.editingDidBegin)
        weight.addTarget(self, action: #selector(textFieldDidEndEditing), for: UIControl.Event.editingDidEnd)
        weight.addTarget(self, action: #selector(textFieldDidBegin), for: UIControl.Event.editingDidBegin)
        age.addTarget(self, action: #selector(textFieldDidEndEditing), for: UIControl.Event.editingDidEnd)
        age.addTarget(self, action: #selector(textFieldDidBegin), for: UIControl.Event.editingDidBegin)
        height.addTarget(self, action: #selector(textFieldDidEndEditing), for: UIControl.Event.editingDidEnd)
        height.addTarget(self, action: #selector(textFieldDidBegin), for: UIControl.Event.editingDidBegin)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let appDefaults: [String:Any] = [self.name.restorationIdentifier! : "Nombre",
                                         self.weight.restorationIdentifier! : "00",
                                         self.age.restorationIdentifier! : "00",
                                         self.height.restorationIdentifier! : "000",
                                         "sex" : "men"]
        
        UserDefaults.standard.register(defaults: appDefaults)
        loadUserDefaults()
    }
    
    func loadUserDefaults() {
        name.text = UserDefaults.standard.string(forKey: name.restorationIdentifier!)
        weight.text = UserDefaults.standard.string(forKey: weight.restorationIdentifier!)
        age.text = UserDefaults.standard.string(forKey: age.restorationIdentifier!)
        height.text = UserDefaults.standard.string(forKey: height.restorationIdentifier!)
        sexImage.image = UIImage(named: UserDefaults.standard.string(forKey: "sex")!)
    }
    
    @objc func textFieldDidEndEditing(_ textField: UITextField)
    {
        if self.textChange != textField.text! {
            UserDefaults.standard.set(textField.text, forKey: textField.restorationIdentifier!)
            UserDefaults.standard.synchronize()
        }
    }
    
    @objc func textFieldDidBegin(_ textField: UITextField)
    {
        self.textChange = textField.text!
    }

    @objc func dismissKeyboard() {
       view.endEditing(true)
    }
    
    @IBAction func changeSex(_ sender: UITapGestureRecognizer) {
        if sexImage.image == UIImage(named: "men") {
            sexImage.image = UIImage(named: "women")
            UserDefaults.standard.set("women", forKey: "sex")
        } else {
            sexImage.image = UIImage(named: "men")
            UserDefaults.standard.set("men", forKey: "sex")
        }
        UserDefaults.standard.synchronize()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
