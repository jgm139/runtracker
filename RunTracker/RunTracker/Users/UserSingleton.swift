//
//  UserSingleton.swift
//  RunTracker
//
//  Created by Pablo López Iborra on 14/03/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import Foundation

class UserSingleton {
    var user: User!

    private init() { }
    
    static var userSingleton = UserSingleton()
}
