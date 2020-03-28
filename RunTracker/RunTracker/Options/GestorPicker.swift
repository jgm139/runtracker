//
//  GestorPicker.swift
//  RunTracker
//
//  Created by Julia García Martínez on 04/03/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import AVFoundation

class GestorPicker: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    let listSounds: [(name: String, soundID: SystemSoundID)] = [("---", 0000), ("Fanfare", 1025), ("Choo Choo", 1323), ("Calyso", 1322), ("SIMToolkitPositiveACK", 1054), ("VCRinging", 1154)]
    var fromVC: String
    let defaults = UserDefaults.standard
    
    init(from viewController: String) {
        fromVC = viewController
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return listSounds.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return listSounds[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0 {
            AudioServicesPlaySystemSound (listSounds[row].soundID)
            print("SystemSoundID \(listSounds[row].soundID)")
            switch fromVC {
                case "CadenceViewController":
                    defaults.set(listSounds[row].soundID, forKey: CadenceConstants.CADENCE_SOUND_NOTIFICATIONS.rawValue)
                    defaults.set(row, forKey: CadenceConstants.CADENCE_INDEX_SOUNDS.rawValue)
                    break
                case "IntervalViewController":
                    defaults.set(listSounds[row].soundID, forKey: IntervalConstants.INTERVAL_SOUND_NOTIFICATIONS.rawValue)
                    defaults.set(row, forKey: IntervalConstants.INTERVAL_INDEX_SOUNDS.rawValue)
                    break
                default:
                    break
            }
        }
    }
    
}
