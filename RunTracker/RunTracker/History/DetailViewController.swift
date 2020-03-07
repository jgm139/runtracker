//
//  DetailViewController.swift
//  RunTracker
//
//  Created by Pablo López Iborra on 07/03/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var seconds = 0
    var distanceTraveled = 0.0
    var rate = 0.0
    var steps = 0
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timeLabel.text = self.timeString(time: TimeInterval(self.seconds))
        self.distanceLabel.text = String(self.distanceTraveled) + " km"
        self.rateLabel.text = NSString.localizedStringWithFormat("%.1f min/km", self.rate) as String
        self.stepsLabel.text = String(self.steps) + " pasos/min"
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}
