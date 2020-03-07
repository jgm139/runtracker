//
//  HistoryTableViewController.swift
//  RunTracker
//
//  Created by Julia García Martínez on 17/02/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewController: UITableViewController {
    
    var listHistory : [History]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        deleteHistory()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let miContexto = miDelegate.persistentContainer.viewContext
        
        let request : NSFetchRequest<History> = NSFetchRequest(entityName:"History")
        //"miContexto" es el contexto de Core Data
        //FALTA el código que obtiene "miContexto", como se ha hecho en ejemplos anteriores
        listHistory = try? miContexto.fetch(request) as! [History]
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listHistory.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "itemHistory", for: indexPath) as! HistoryTableViewCell

        
        cell.dateLabel.text = self.dateString(date: self.listHistory[indexPath.row].date!)
        cell.distanceLabel.text = String(self.listHistory[indexPath.row].km)
        cell.timeLabel.text = self.timeString(time: TimeInterval(self.listHistory[indexPath.row].time))

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "detailSegue", sender: self)
    }
    
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destiny = segue.destination as! DetailViewController
                
                destiny.seconds = Int(self.listHistory[indexPath.row].time)
                destiny.distanceTraveled = self.listHistory[indexPath.row].km
                destiny.rate = self.listHistory[indexPath.row].rate
                destiny.steps = Int(self.listHistory[indexPath.row].step)
            }
        }
    }
    
    
    func deleteHistory(){
        guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let miContexto = miDelegate.persistentContainer.viewContext
        
        let request : NSFetchRequest<History> = NSFetchRequest(entityName:"History")
        //"miContexto" es el contexto de Core Data
        //FALTA el código que obtiene "miContexto", como se ha hecho en ejemplos anteriores
        listHistory = try? miContexto.fetch(request) as! [History]
        
        for history in listHistory{
            miContexto.delete(history)
        }
        
        do {
           try miContexto.save()
        } catch {
           print("Error al guardar el contexto: \(error)")
        }
    }
    
}
