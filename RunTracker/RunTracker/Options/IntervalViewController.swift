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
    
    // MARK: - Outlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var labelValue: UILabel!
    @IBOutlet weak var labelUnit: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var switchNotifications: UISwitch!
    
    // MARK: - Variables
    let gestorPicker = GestorPicker(from: "IntervalViewController")
    let defaults = UserDefaults.standard
    var measure: String?
    
    // MARK: - View Controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Intervalos"
        
        self.pickerView.dataSource = self.gestorPicker
        self.pickerView.delegate = self.gestorPicker
        
        measure = defaults.string(forKey: IntervalConstants.INTERVAL_MEASURE.raw())
        
        if measure == nil {
            defaults.set("TIME", forKey: IntervalConstants.INTERVAL_MEASURE.raw())
            measure = "TIME"
        }
        
        /*if measure == "TIME" {
            slider.maximumValue = 60
            labelUnit.text = "min"
        } else if measure == "DISTANCE" {
            slider.maximumValue = 1000
            labelUnit.text = "m"
        }*/
        
        let notificationsOn: Bool = defaults.bool(forKey: IntervalConstants.INTERVAL_NOTIFICATIONS.raw())
        switchNotifications.setOn(notificationsOn, animated: true)
        
        if notificationsOn {
            turnOnNotifications()
        } else {
            turnOffNotifications()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if measure == "TIME" {
            segmentedControl.selectedSegmentIndex = 0;
            slider.maximumValue = 60
            labelUnit.text = "min"
            slider.value = defaults.float(forKey: IntervalConstants.INTERVAL_TIME.raw())
        } else {
            segmentedControl.selectedSegmentIndex = 1;
            slider.maximumValue = 1000
            labelUnit.text = "m"
            slider.value = defaults.float(forKey: IntervalConstants.INTERVAL_DISTANCE.raw())
        }
        
        labelValue.text = "\(Int(slider.value))"
    }
    
    // MARK: - Actions
    @IBAction func valueSliderChanged(_ sender: UISlider) {
        labelValue.text = "\(Int(slider.value))"
        
        if measure == "TIME" {
            print(slider.value)
            defaults.set(slider.value, forKey: IntervalConstants.INTERVAL_TIME.raw())
        } else {
            defaults.set(slider.value, forKey: IntervalConstants.INTERVAL_DISTANCE.raw())
        }
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
            case 0:
                defaults.set("TIME", forKey: IntervalConstants.INTERVAL_MEASURE.raw())
                slider.value = defaults.float(forKey: IntervalConstants.INTERVAL_TIME.raw())
                
                if slider.value <= 0 {
                    turnOffNotifications()
                    defaults.set(false, forKey: IntervalConstants.INTERVAL_NOTIFICATIONS.raw())
                    self.switchNotifications.isOn = false
                } else {
                    turnOnNotifications()
                    defaults.set(true, forKey: IntervalConstants.INTERVAL_NOTIFICATIONS.raw())
                    self.switchNotifications.isOn = true
                }
                
                labelValue.text = "\(Int(slider.value))"
                slider.maximumValue = 60
                labelUnit.text = "min"
                break
            case 1:
                defaults.set("DISTANCE", forKey: IntervalConstants.INTERVAL_MEASURE.raw())
                slider.value = defaults.float(forKey: IntervalConstants.INTERVAL_DISTANCE.raw())
                
                if slider.value <= 0 {
                    turnOffNotifications()
                    defaults.set(false, forKey: IntervalConstants.INTERVAL_NOTIFICATIONS.raw())
                    self.switchNotifications.isOn = false
                } else {
                    turnOnNotifications()
                    defaults.set(true, forKey: IntervalConstants.INTERVAL_NOTIFICATIONS.raw())
                    self.switchNotifications.isOn = true
                }
                
                labelValue.text = "\(Int(slider.value))"
                slider.maximumValue = 1000
                labelUnit.text = "m"
                break
            default:
                break
        }
    }
    
    @IBAction func switchChanged(_ sender: Any) {
        if self.switchNotifications.isOn {
            defaults.set(true, forKey: IntervalConstants.INTERVAL_NOTIFICATIONS.raw())
            turnOnNotifications()
        } else {
            defaults.set(false, forKey: IntervalConstants.INTERVAL_NOTIFICATIONS.raw())
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
        
        let index: Int = defaults.integer(forKey: IntervalConstants.INTERVAL_INDEX_SOUNDS.raw())
        pickerView.selectRow(index, inComponent: 0, animated: true)
    }

}
