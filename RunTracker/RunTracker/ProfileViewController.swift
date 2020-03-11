//
//  ProfileViewController.swift
//  RunTracker
//
//  Created by Julia García Martínez on 17/02/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var height: UITextField!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var sexImage: UIImageView!
    
    // MARK: - Variables
    var textChange: String = ""
    
    // MARK: - View Controller methods
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
        
        let tapView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapView)
        
        let appDefaults: [String:Any] = [self.name.restorationIdentifier! : "Nombre",
                                         self.weight.restorationIdentifier! : "00",
                                         self.age.restorationIdentifier! : "00",
                                         self.height.restorationIdentifier! : "000",
                                         "sex" : "men"]
        
        UserDefaults.standard.register(defaults: appDefaults)
        loadUserDefaults()
    }
    
    // MARK: - Methods
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
    
    // MARK: - Actions
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
    
    @IBAction func exportImage(_ sender: UITapGestureRecognizer) {
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        image.allowsEditing = false
        
        self.present(image, animated: true) {
            
        }
    }
    
    // MARK: - Picker Controller Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        self.imageProfile.image = image
        self.imageProfile.contentMode = .scaleAspectFill
            
        self.dismiss(animated: true, completion: nil)
    }
}
