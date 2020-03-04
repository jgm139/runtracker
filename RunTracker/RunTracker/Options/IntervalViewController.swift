//
//  IntervalViewController.swift
//  RunTracker
//
//  Created by Julia García Martínez on 01/03/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import AVFoundation

class IntervalViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var labelValue: UILabel!
    @IBOutlet weak var labelUnit: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    // Gestor del PickerView
    let gestorPicker = GestorPicker()
    
    // Tweet sound
    let systemSoundID: SystemSoundID = 1016
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //AudioServicesPlaySystemSound (systemSoundID)
        
        navigationItem.title = "Intervalos"
        
        labelValue.text = "\(Int(slider.value))"
        
        self.pickerView.dataSource = self.gestorPicker
        self.pickerView.delegate = self.gestorPicker
    }

    @IBAction func valueSliderChanged(_ sender: UISlider) {
        labelValue.text = "\(Int(slider.value))"
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
            case 0:
                slider.maximumValue = 60
                labelUnit.text = "min"
                break
            case 1:
                slider.maximumValue = 1000
                labelUnit.text = "m"
            default:
                break
        }
    }

}
