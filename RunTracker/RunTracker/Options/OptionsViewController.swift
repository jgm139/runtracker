//
//  OptionsViewController.swift
//  RunTracker
//
//  Created by Julia García Martínez on 26/02/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import Foundation
import QuickTableViewController

final class OptionsViewController: QuickTableViewController {
    
    // MARK: - Variables
    let defaults = UserDefaults.standard

    // MARK: View Controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let optionSelected = defaults.string(forKey: AccuracyGPS.GPS_KEY.raw())
        var optionsValues: (optimum: Bool, medium: Bool, low: Bool) = (true, false, false)
        
        switch optionSelected {
            case AccuracyGPS.GPS_OPTIMUM.raw():
                optionsValues = (true, false, false)
                break
            case AccuracyGPS.GPS_MEDIUM.raw():
                optionsValues = (false, true, false)
                break
            case AccuracyGPS.GPS_LOW.raw():
                optionsValues = (false, false, true)
                break
            default:
                break
        }

        tableContents = [
            
        Section(title: "Notificaciones", rows: [
            NavigationRow(text: "Cadencia", detailText: .none, icon: .image(UIImage(systemName: "timer")!), action: { [weak self] _ in
                let resultViewController = storyBoard.instantiateViewController(withIdentifier: "CadenceViewController") as! CadenceViewController
                self?.navigationController?.pushViewController(resultViewController, animated: true)
            }),
            NavigationRow(text: "Intervalos", detailText: .none, icon: .image(UIImage(systemName: "stopwatch")!), action: { [weak self] _ in
            let resultViewController = storyBoard.instantiateViewController(withIdentifier: "IntervalViewController") as! IntervalViewController
            self?.navigationController?.pushViewController(resultViewController, animated: true) })
        ]),
                
                
        Section(title: "Entreno", rows: [
            SwitchRow(text: "Autopause", switchValue: true, action: { _ in })
        ]),
        
        RadioSection(title: "Precisión GPS", options: [
            OptionRow(text: "Óptima", isSelected: optionsValues.optimum, action: didToggleSelection()),
            OptionRow(text: "Media", isSelected: optionsValues.medium, action: didToggleSelection()),
            OptionRow(text: "Baja", isSelected: optionsValues.low, action: didToggleSelection())
        ], footer: "Elige el nivel de precisión del GPS."),

        Section(title: "Conectividad", rows: [
            NavigationRow(text: "Banda HRM", detailText: .none, icon: .image(UIImage(systemName: "heart")!), action: { [weak self] _ in
            let resultViewController = storyBoard.instantiateViewController(withIdentifier: "HRMViewController") as! HRMViewController
            self?.navigationController?.pushViewController(resultViewController, animated: true) })
        ]),
            
        ]
    }
    
    // MARK: - Methods
    private func didToggleSelection() -> (Row) -> Void {
        return { [weak self] in
            if let option = $0 as? OptionRowCompatible {
                switch option.text {
                    case AccuracyGPS.GPS_OPTIMUM.raw():
                        self!.defaults.set(AccuracyGPS.GPS_OPTIMUM.raw(), forKey: AccuracyGPS.GPS_KEY.raw())
                        break
                    case AccuracyGPS.GPS_MEDIUM.raw():
                        self!.defaults.set(AccuracyGPS.GPS_MEDIUM.raw(), forKey: AccuracyGPS.GPS_KEY.raw())
                        break
                    case AccuracyGPS.GPS_LOW.raw():
                        self!.defaults.set(AccuracyGPS.GPS_LOW.raw(), forKey: AccuracyGPS.GPS_KEY.raw())
                        break
                    default:
                        break
                }
            }
        }
    }
    
}
