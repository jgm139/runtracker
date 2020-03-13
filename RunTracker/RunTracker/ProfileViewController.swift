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
    func checkUserExist() -> Bool {
        guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        let miContexto = miDelegate.persistentContainer.viewContext
        
        let request : NSFetchRequest<User> = NSFetchRequest(entityName:"User")
        
        do {
            let user = try miContexto.fetch(request)
            if user.count > 0 {
                return true
            }
        } catch {
            print("Error while fetching the user")
        }
        return false
    }
    
    func loadData() {
        do {
            if checkUserExist() == true {
                guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
                let miContexto = miDelegate.persistentContainer.viewContext
                
                let request : NSFetchRequest<User> = NSFetchRequest(entityName:"User")
                
                let user = try miContexto.fetch(request)
                
                self.name.text = user[0].name
                self.weight.text = user[0].weight
                self.age.text = user[0].age
                self.height.text = user[0].height
                
                if user[0].sex == "men" {
                    sexImage.image = UIImage(named: "men")
                } else {
                    sexImage.image = UIImage(named: "women")
                }
                
                self.imageProfile.image = UIImage(data: user[0].image!)
                self.imageProfile.contentMode = .scaleAspectFill
            } else {
                sexImage.image = UIImage(named: "men")
            }
        } catch {
            print("Error while fetching the user")
        }
    }
    
    @IBAction func saveData(_ sender: Any) {
        guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let miContexto = miDelegate.persistentContainer.viewContext
        
        if self.checkUserExist() == false {
            let user = User(context: miContexto)
            user.name = self.name.text
            user.weight = self.weight.text
            user.age = self.age.text
            user.height = self.height.text
            
            if sexImage.image == UIImage(named: "men") {
                user.sex = "men"
            } else {
                user.sex = "women"
            }
          user.image = self.imageProfile.image?.pngData()
        } else {
            let request : NSFetchRequest<User> = NSFetchRequest(entityName:"User")
            do {
                let user = try miContexto.fetch(request)
                if user.count > 0 {
                    user[0].name = self.name.text
                    user[0].weight = self.weight.text
                    user[0].age = self.age.text
                    user[0].height = self.height.text
                    
                    if user[0].sex == "men" {
                        user[0].sex = "men"
                    } else {
                        user[0].sex = "women"
                    }
                    user[0].image = self.imageProfile.image?.pngData()
                }
            } catch {
                print("Error while fetching the user")
            }
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
