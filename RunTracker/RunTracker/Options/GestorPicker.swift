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
    let listSounds: [(name: String, soundID: SystemSoundID)] = [("Fanfare", 1025), ("Choo Choo", 1323), ("Calyso", 1322), ("SIMToolkitPositiveACK", 1054), ("VCRinging", 1154)]
    
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
        // Aquí se guardaría en las UserDefaults el sonido escogido como notificación
        print("Fila seleccionada: \(row), dato: \(listSounds[row])")
        AudioServicesPlaySystemSound (listSounds[row].soundID)
    }
    
}
