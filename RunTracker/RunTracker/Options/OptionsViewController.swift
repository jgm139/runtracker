//
//  OptionsViewController.swift
//  RunTracker
//
//  Created by Julia García Martínez on 26/02/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import Foundation
import QuickTableViewController
import CoreData

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
        
        let autopause = defaults.bool(forKey: AutopauseConstants.AUTOPAUSE_KEY.raw())

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
            SwitchRow(text: "Autopause", switchValue: autopause, action: didSwitchSwitch())
        ]),
        
        RadioSection(title: "Precisión GPS", options: [
            OptionRow(text: "Óptima", isSelected: optionsValues.optimum, action: didToggleSelection()),
            OptionRow(text: "Media", isSelected: optionsValues.medium, action: didToggleSelection()),
            OptionRow(text: "Baja", isSelected: optionsValues.low, action: didToggleSelection())
        ], footer: "Elige el nivel de precisión del GPS."),

        Section(title: "Conectividad", rows: [
            NavigationRow(text: "MI Band 2", detailText: .none, icon: .image(UIImage(systemName: "heart")!), action: { [weak self] _ in
            let resultViewController = storyBoard.instantiateViewController(withIdentifier: "HRMViewController") as! HRMViewController
            self?.navigationController?.pushViewController(resultViewController, animated: true) })
        ]),
        
        Section(title: "", rows: [
          TapActionRow<CustomTapActionCell>(text: "Cerrar sesión", action: { [weak self] in self?.signOut($0) })
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
    
    private func didSwitchSwitch() -> (Row) -> Void {
        return { [weak self] in
            if let row = $0 as? SwitchRowCompatible {
                if row.switchValue {
                    self!.defaults.set(true, forKey: AutopauseConstants.AUTOPAUSE_KEY.raw())
                } else {
                    self!.defaults.set(false, forKey: AutopauseConstants.AUTOPAUSE_KEY.raw())
                }
            }
        }
    }
    
    private func signOut(_ sender: Row) {
        let alert = UIAlertController(title: "¿Cerrar Sesión?", message: "¿Está seguro de que desea continuar con esta acción?",         preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.default, handler: { _ in
            
        }))
        alert.addAction(UIAlertAction(title: "Cerrar sesión", style: UIAlertAction.Style.destructive, handler: {(_: UIAlertAction!) in
            self.signOutAction()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func signOutAction() {
        guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let miContexto = miDelegate.persistentContainer.viewContext
        
        let request : NSFetchRequest<Session> = NSFetchRequest(entityName:"Session")
        let session = try? miContexto.fetch(request)
        
        if session!.count > 0 {
            miContexto.delete(session![0])
        }
        do {
            try miContexto.save()
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "First") as! UINavigationController
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
        } catch {
           print("Error al guardar el contexto: \(error)")
        }
    }
    
}

final class CustomTapActionCell: TapActionCell {

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    tintColor = .red
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    tintColor = .red
  }

}
