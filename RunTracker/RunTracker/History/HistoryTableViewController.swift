//
//  HistoryTableViewController.swift
//  RunTracker
//
//  Created by Julia García Martínez on 17/02/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class HistoryTableViewController: UITableViewController {
    
    // MARK: - Variables
    var listHistory : [History]!
    
    // MARK: - View Controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        listHistory = UserSingleton.userSingleton.histories?.allObjects as? [History]
        listHistory.sort(by: {$0.date!.timeIntervalSinceNow > $1.date!.timeIntervalSinceNow})
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listHistory.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemHistory", for: indexPath) as! HistoryTableViewCell

        cell.dateLabel.text = self.dateString(date: self.listHistory[indexPath.row].date!)
        cell.distanceLabel.text = String(self.listHistory[indexPath.row].km)
        cell.timeLabel.text = self.timeString(time: TimeInterval(self.listHistory[indexPath.row].time))

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "detailSegue", sender: self)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let miContexto = miDelegate.persistentContainer.viewContext
            
            do{
                miContexto.delete(listHistory[indexPath.row])
                listHistory.remove(at: indexPath.row)
                do {
                    try miContexto.save()
                    tableView.reloadData()
                } catch {
                    print(error)
                }
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destiny = segue.destination as! DetailViewController
                
                destiny.seconds = Int(self.listHistory[indexPath.row].time)
                destiny.distanceTraveled = self.listHistory[indexPath.row].km
                destiny.rate = self.listHistory[indexPath.row].rate
                destiny.steps = Int(self.listHistory[indexPath.row].step)
                
                if let locations = self.listHistory[indexPath.row].locations {
                    destiny.locationsHistory = locations.allObjects as! [Location]
                }
            }
        }
    }
    
    // MARK: - Core Data
    func deleteHistory(){
        guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let miContexto = miDelegate.persistentContainer.viewContext
        
        let request : NSFetchRequest<History> = NSFetchRequest(entityName:"History")
        listHistory = try? miContexto.fetch(request) 
        
        for history in listHistory{
            miContexto.delete(history)
        }
        
        do {
           try miContexto.save()
        } catch {
           print("Error al guardar el contexto: \(error)")
        }
    }
    
    // MARK: - Methods
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func dateString(date:Date) -> String {
        let formatter = DateFormatter()
        //2016-12-08 03:37:22 +0000
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from:date)
    }
    
}
