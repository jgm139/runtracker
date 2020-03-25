//
//  ProfileViewController.swift
//  RunTracker
//
//  Created by Julia García Martínez on 17/02/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreData

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
        
        let tapView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapView)
        
        loadData()
    }
    
    // MARK: - Methods
    func loadData() {
        self.name.text = UserSingleton.userSingleton.user.name
        self.weight.text = UserSingleton.userSingleton.user.weight
        self.age.text = UserSingleton.userSingleton.user.age
        self.height.text = UserSingleton.userSingleton.user.height
        
        if UserSingleton.userSingleton.user.sex == "men" {
            sexImage.image = UIImage(named: "men")
        } else {
            sexImage.image = UIImage(named: "women")
        }
        
        self.imageProfile.image = UIImage(data: UserSingleton.userSingleton.user.image!)
        self.imageProfile.contentMode = .scaleAspectFill
    }
    
    @IBAction func saveData(_ sender: Any) {
        guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let miContexto = miDelegate.persistentContainer.viewContext
        
        let request : NSFetchRequest<User> = NSFetchRequest(entityName:"User")
        do {
            let users = try miContexto.fetch(request)
            
            for user in users {
                if user == UserSingleton.userSingleton.user {
                    user.name = self.name.text
                    user.weight = self.weight.text
                    user.age = self.age.text
                    user.height = self.height.text
                    
                    if user.sex == "men" {
                        user.sex = "men"
                    } else {
                        user.sex = "women"
                    }
                    user.image = self.imageProfile.image?.pngData()
                    
                    UserSingleton.userSingleton.user = user
                }
            }
        } catch {
            print("Error buscando usuarios")
        }
        
        do {
           try miContexto.save()
        } catch {
           print("Error al guardar el contexto: \(error)")
        }
    }
    
    @IBAction func changeSex(_ sender: UITapGestureRecognizer) {
        if sexImage.image == UIImage(named: "men") {
            sexImage.image = UIImage(named: "women")
        } else {
            sexImage.image = UIImage(named: "men")
        }
    }
    
    @objc func dismissKeyboard() {
       view.endEditing(true)
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
