//
//  OptionsTableViewController.swift
//  RunTracker
//
//  Created by Julia García Martínez on 17/02/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit

class OptionsTableViewController: UITableViewController {
    
    // MARK: - Properties
    let headerOptions = ["Notificaciones", "Entreno", "Conectividad"]
    let options = [["Cadencia", "Intervalos"], ["Precisión GPS", "Autopause"], ["Banda HRM", "Watch"]]
    let iconOptions = [["cadencia.png", "intervalos.png"], ["map.png", "pause.png"], ["banda_hrm.png", "watch.png"]]
    @IBOutlet var optionsTableView: UITableView!
    
    
    // MARK: - View Functions

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return headerOptions.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemOptions", for: indexPath) as? OptionsTableViewCell else {
            fatalError("The dequeued cell is not an instance of OptionsTableViewCell.")
        }
        
        cell.optionsTitle.text = options[indexPath.section][indexPath.row]
        cell.optionsIcon.image = UIImage(named: iconOptions[indexPath.section][indexPath.row])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < headerOptions.count {
            return headerOptions[section]
        }
        
        return nil
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailOptions" {
            if let detail = segue.destination as? DetailOptionsViewController {
                detail.optionSelected = options[self.optionsTableView.indexPathForSelectedRow!.section][self.optionsTableView.indexPathForSelectedRow!.row]
            }
        }
    }

}
