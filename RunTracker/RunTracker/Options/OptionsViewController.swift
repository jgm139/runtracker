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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

        tableContents = [
            
        Section(title: "Notificaciones", rows: [
            SwitchRow(text: "Notificaciones acústicas", switchValue: true, action: { _ in }),
            NavigationRow(text: "Cadencia", detailText: .none, icon: .image(UIImage(systemName: "timer")!), action: { [weak self] _ in
                let resultViewController = storyBoard.instantiateViewController(withIdentifier: "CadenceViewController") as! CadenceViewController
                self?.navigationController?.pushViewController(resultViewController, animated: true)
            }),
            NavigationRow(text: "Intervalos", detailText: .none, icon: .image(UIImage(systemName: "stopwatch")!), action: { [weak self] _ in
            let resultViewController = storyBoard.instantiateViewController(withIdentifier: "IntervalViewController") as! IntervalViewController
            self?.navigationController?.pushViewController(resultViewController, animated: true) })
        ]),
                
                
        Section(title: "Entreno", rows: [
            NavigationRow(text: "Precisión GPS", detailText: .none, icon: .image(UIImage(systemName: "map")!), action: { [weak self] _ in
            let resultViewController = storyBoard.instantiateViewController(withIdentifier: "GPSViewController") as! GPSViewController
            self?.navigationController?.pushViewController(resultViewController, animated: true) }),
            SwitchRow(text: "Autopause", switchValue: true, action: { _ in })
        ]),

        Section(title: "Conectividad", rows: [
            NavigationRow(text: "Banda HRM", detailText: .none, icon: .image(UIImage(systemName: "heart")!), action: { [weak self] _ in
            let resultViewController = storyBoard.instantiateViewController(withIdentifier: "HRMViewController") as! HRMViewController
            self?.navigationController?.pushViewController(resultViewController, animated: true) }),
            NavigationRow(text: "Watch", detailText: .none, icon: .image(UIImage(systemName: "clock")!), action: { [weak self] _ in
            let resultViewController = storyBoard.instantiateViewController(withIdentifier: "WatchViewController") as! WatchViewController
            self?.navigationController?.pushViewController(resultViewController, animated: true) })
        ]),
            
        ]
    }
    
}
