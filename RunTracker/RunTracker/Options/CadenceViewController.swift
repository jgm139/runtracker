//
//  CadenceViewController.swift
//  RunTracker
//
//  Created by Julia García Martínez on 26/02/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit

class CadenceViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var labelValue: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var switchNotifications: UISwitch!
    
    // MARK: - Variables
    let gestorPicker = GestorPicker(from: "CadenceViewController")
    let defaults = UserDefaults.standard
    
    // MARK: - View Controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Cadencia"
        
        self.pickerView.dataSource = self.gestorPicker
        self.pickerView.delegate = self.gestorPicker
        
        slider.value = defaults.float(forKey: CadenceConstants.CADENCE_STEPS_PER_MIN.raw())
        
        let notificationsOn: Bool = defaults.bool(forKey: CadenceConstants.CADENCE_NOTIFICATIONS.raw())
        switchNotifications.setOn(notificationsOn, animated: true)
        
        if notificationsOn {
            turnOnNotifications()
        } else {
            turnOffNotifications()
        }
        
        labelValue.text = "\(Int(slider.value))"
    }
    
    // MARK: - Actions
    @IBAction func valueSliderChanged(_ sender: Any) {
        labelValue.text = "\(Int(slider.value))"
        defaults.set(slider.value, forKey: CadenceConstants.CADENCE_STEPS_PER_MIN.raw())
    }
    
    @IBAction func switchChanged(_ sender: Any) {
        if self.switchNotifications.isOn {
            defaults.set(true, forKey: CadenceConstants.CADENCE_NOTIFICATIONS.raw())
            turnOnNotifications()
        } else {
            defaults.set(false, forKey: CadenceConstants.CADENCE_NOTIFICATIONS.raw())
            turnOffNotifications()
        }
    }
    
    // MARK: - Methods
    private func turnOffNotifications() {
        pickerView.isUserInteractionEnabled = false
        pickerView.alpha = 0.5
        pickerView.selectRow(0, inComponent: 0, animated: true)
    }
    
    private func turnOnNotifications() {
        pickerView.isUserInteractionEnabled = true
        pickerView.alpha = 1
        
        let index: Int = defaults.integer(forKey: CadenceConstants.CADENCE_INDEX_SOUNDS.raw())
        pickerView.selectRow(index, inComponent: 0, animated: true)
        
        if defaults.float(forKey: CadenceConstants.CADENCE_STEPS_PER_MIN.raw()) <= 0.0 {
            defaults.set(slider.value, forKey: CadenceConstants.CADENCE_STEPS_PER_MIN.raw())
        }
    }
    
}
