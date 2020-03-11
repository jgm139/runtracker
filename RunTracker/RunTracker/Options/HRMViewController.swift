//
//  HRMViewController.swift
//  RunTracker
//
//  Created by Julia García Martínez on 01/03/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuickTableViewController

class HRMViewController: QuickTableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var vConnection: UIImageView!
    @IBOutlet weak var lConnection: UILabel!
    @IBOutlet weak var vBattery: UIImageView!
    @IBOutlet weak var lBattery: UILabel!
    @IBOutlet weak var vHeartRate: UIImageView!
    @IBOutlet weak var lHeartRate: UILabel!
    
    // MARK: - Variables
    var centralManager: CBCentralManager!
    var miBand: MiBand2!

    // MARK: - View Controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Banda HRM"
        
        centralManager = CBCentralManager()
        centralManager.delegate = self
    }
    
    // MARK: - Methods to update views
    func updateBattery(_ battery: Int) {
        switch battery {
            case 0:
                vBattery.image = UIImage(named: "battery0")
                break
            case 1..<25:
                vBattery.image = UIImage(named: "battery25")
                break
            case 26..<50:
                vBattery.image = UIImage(named: "battery50")
                break
            case 51..<75:
                vBattery.image = UIImage(named: "battery75")
                break
            case 76..<100:
                vBattery.image = UIImage(named: "battery100")
                break
            default:
                vBattery.image = UIImage(named: "batteryUnknown")
                break
        }
    }
    
    func updateHeartRate(_ heartRate: Int) {
        self.stopHeartBeatAnimation()
        miBand.startVibrate()
        self.lHeartRate.text = heartRate.description
    }
    
    func startHeartBeatAnimation(){
        let pulse1 = CASpringAnimation(keyPath: "transform.scale")
        pulse1.duration = 0.6
        pulse1.fromValue = 1.0
        pulse1.toValue = 1.12
        pulse1.autoreverses = true
        pulse1.repeatCount = 1
        pulse1.initialVelocity = 0.5
        pulse1.damping = 0.8
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.5
        animationGroup.repeatCount = 1000
        animationGroup.animations = [pulse1]
        
        self.vHeartRate.layer.add(animationGroup, forKey: "pulse")
    }
    
    func stopHeartBeatAnimation(){
        self.vHeartRate.layer.removeAllAnimations()
    }
    
    // MARK: - Central Manager Delegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .poweredOn:
                let lastPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [MiBand2Service.UUID_SERVICE_MIBAND2_SERVICE])
                
                if lastPeripherals.count > 0 {
                    let device = lastPeripherals.first! as CBPeripheral
                    miBand = MiBand2(device)
                    centralManager.connect(miBand.peripheral, options: nil)
                } else {
                    centralManager.scanForPeripherals(withServices: nil, options: nil)
                }
                
            default:
                break
        }
    }
    
    private func centralManager(_ central: CBPeripheral, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if peripheral.name == "MI Band 2" {
            miBand = MiBand2(peripheral)
            print("Trying to connect to \(String(describing: peripheral.name))")
            centralManager.connect(miBand.peripheral, options: nil)
        } else {
            print("Discovered: \(String(describing: peripheral.name))")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        miBand.peripheral.delegate = self
        miBand.peripheral.discoverServices(nil)
    }
    
    // MARK: - Peripheral Delegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let servicePeripherals = peripheral.services {
            for servicePeripheral in servicePeripherals {
                peripheral.discoverCharacteristics(nil, for: servicePeripheral)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for cc in characteristics {
                switch cc.uuid.uuidString {
                case MiBand2Service.UUID_CHARACTERISTIC_6_BATTERY_INFO.uuidString:
                    peripheral.readValue(for: cc)
                    break
                case MiBand2Service.UUID_CHARACTERISTIC_HEART_RATE_DATA.uuidString:
                    peripheral.setNotifyValue(true, for: cc)
                    break
                default:
                    print("Service: " + service.uuid.uuidString + " Characteristic: " + cc.uuid.uuidString)
                    break
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid.uuidString{
            case MiBand2Service.UUID_CHARACTERISTIC_6_BATTERY_INFO.uuidString:
                updateBattery(miBand.getBattery(batteryData: characteristic.value!))
                break
            case MiBand2Service.UUID_CHARACTERISTIC_HEART_RATE_DATA.uuidString:
                updateHeartRate(miBand.getHeartRate(heartRateData: characteristic.value!))
                break
            default:
                print(characteristic.uuid.uuidString)
                break
        }
    }

}
