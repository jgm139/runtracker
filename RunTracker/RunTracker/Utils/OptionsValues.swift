//
//  OptionsValues.swift
//  RunTracker
//
//  Created by Julia García Martínez on 14/03/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import Foundation
import AVFoundation

class OptionsValues {
    
    // MARK: Attributes
    public static let MAX_MINS_PAUSED: Int = 1
    private let defaults = UserDefaults.standard
    private var cadenceValues: (cadence: Int, useNotifications: Bool, idSound: SystemSoundID)
    private var intervalValues: (measure: String, measureValue: Int, useNotifications: Bool, idSound: SystemSoundID)?
    private var autopauseValue: Bool
    private var accuracyGPS: String
    
    init() {
        // Cadence Values
        self.cadenceValues.cadence = Int(defaults.float(forKey: CadenceConstants.CADENCE_STEPS_PER_MIN.raw()))
        self.cadenceValues.useNotifications = defaults.bool(forKey: CadenceConstants.CADENCE_NOTIFICATIONS.raw())
        self.cadenceValues.idSound = defaults.object(forKey: CadenceConstants.CADENCE_SOUND_NOTIFICATIONS.rawValue) as? SystemSoundID ?? 0000
        //print("Cadence Values \(self.cadenceValues.idSound)")
        
        // Interval Values
        self.intervalValues = (measure: "", measureValue: 0, useNotifications: false, idSound: 0000)
        if let measure = defaults.string(forKey: IntervalConstants.INTERVAL_MEASURE.raw()) {
            self.intervalValues?.measure = measure
            
            if measure == "TIME" {
                self.intervalValues?.measureValue = Int(defaults.float(forKey: IntervalConstants.INTERVAL_TIME.raw()))
            } else {
                self.intervalValues?.measureValue = Int(defaults.float(forKey: IntervalConstants.INTERVAL_DISTANCE.raw()))
            }
            
            self.intervalValues?.useNotifications = defaults.bool(forKey: IntervalConstants.INTERVAL_NOTIFICATIONS.raw())
            self.intervalValues?.idSound = defaults.object(forKey: IntervalConstants.INTERVAL_SOUND_NOTIFICATIONS.raw()) as! SystemSoundID
        }
        
        // Autopause
        self.autopauseValue = defaults.bool(forKey: AutopauseConstants.AUTOPAUSE_KEY.raw())
        
        // GPS
        self.accuracyGPS = ""
        if let accuracy = defaults.string(forKey: AccuracyGPS.GPS_KEY.raw()) {
            self.accuracyGPS = accuracy
        }
    }
    
    func getCadenceValues() -> (cadence: Int, useNotifications: Bool, idSound: SystemSoundID) {
        return self.cadenceValues
    }
    
    func getIntervalValues() -> (measure: String, measureValue: Int, useNotifications: Bool, idSound: SystemSoundID)? {
        return self.intervalValues
    }
    
    func getAutopauseValue() -> Bool {
        return self.autopauseValue
    }
    
    func getGPSAccuracy() -> String? {
        return self.accuracyGPS
    }
}
