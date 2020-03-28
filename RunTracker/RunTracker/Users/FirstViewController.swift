//
//  FirstViewController.swift
//  RunTracker
//
//  Created by Pablo López Iborra on 14/03/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreData

class FirstViewController: UIViewController {
    
    // MARK: - View Controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.checkSession()
    }
    
    // MARK: - Core Data
    func checkSession(){
        guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let miContexto = miDelegate.persistentContainer.viewContext
        
        let requestSession : NSFetchRequest<Session> = NSFetchRequest(entityName:"Session")
        let session = try? miContexto.fetch(requestSession)
        
        if session!.count > 0 {
            let requestUser : NSFetchRequest<User> = NSFetchRequest(entityName:"User")
            let users = try? miContexto.fetch(requestUser)
            
            var loadSession = false
            for user in users! {
                if user.username == session![0].username {
                    UserSingleton.userSingleton.user = user
                    loadSession = true
                }
            }
            if loadSession == true {
                self.performSegue(withIdentifier: "sessionInit", sender: nil)
            }
        }
    }

}
