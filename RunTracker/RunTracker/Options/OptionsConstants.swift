//
//  OptionsConstants.swift
//  RunTracker
//
//  Created by Julia García Martínez on 08/03/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import Foundation

enum CadenceConstants: String {
    case CADENCE_STEPS_PER_MIN = "cadence_steps_per_min"
    case CADENCE_NOTIFICATIONS = "cadence_use_notifications"
    case CADENCE_SOUND_NOTIFICATIONS = "cadence_sound_notifications"
    case CADENCE_INDEX_SOUNDS = "cadence_index_sound"
    
    func raw() -> String { self.rawValue }
}
    
enum IntervalConstants: String {
    case INTERVAL_MEASURE = "interval_measure"
    case INTERVAL_TIME = "interval_time"
    case INTERVAL_DISTANCE = "interval_distance"
    case INTERVAL_NOTIFICATIONS = "interval_use_notifications"
    case INTERVAL_SOUND_NOTIFICATIONS = "interval_sound_notifications"
    case INTERVAL_INDEX_SOUNDS = "interval_index_sound"
    
    func raw() -> String { self.rawValue }
}
    
enum AccuracyGPS: String {
    case GPS_KEY = "gps_key"
    case GPS_OPTIMUM = "Óptima"
    case GPS_MEDIUM = "Media"
    case GPS_LOW = "Baja"
    
    func raw() -> String { self.rawValue }
}

enum AutopauseConstants: String {
    case AUTOPAUSE_KEY = "autopause_key"
    
    func raw() -> String { self.rawValue }
}

