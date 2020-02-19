//
//  DetailOptionsViewController.swift
//  RunTracker
//
//  Created by Julia García Martínez on 19/02/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit

class DetailOptionsViewController: UIViewController {
    
    // MARK: - Properties
    var optionSelected = ""
    @IBOutlet weak var titleView: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleView.title = optionSelected
    }

}
