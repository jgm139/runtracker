//
//  TrainingViewController.swift
//  RunTracker
//
//  Created by Julia García Martínez on 17/02/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreMotion
import CoreData

class TrainingViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var buttonPlay: UIButton!
    var timer = Timer()
    var seconds = 0
    var isTimerRunning = false
    var startLocation: CLLocation!
    var distanceTraveled: Double = 0
    var pedometer = CMPedometer()
    var activityManager = CMMotionActivityManager()
    var steps = 0
    var rate:Double = 0
    var saved = false
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var cadenceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    fileprivate let locationManager:CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    private var locationsHistory: [CLLocation] = []
    var isPaused = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressPlay))
        longPress.minimumPressDuration = 1.5
        self.buttonPlay.addGestureRecognizer(longPress)
        
        self.view.addSubview(mapView)
        self.view.addSubview(buttonPlay)
        self.view.insertSubview(buttonPlay, aboveSubview: self.mapView)
        
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.showsCompass = true
        self.mapView.showsScale = true
        self.mapView.userTrackingMode = .follow
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.allowsBackgroundLocationUpdates = true
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
            
        default:
            locationManager.stopUpdatingLocation()
            mapView.showsUserLocation = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let currentLocation = location.coordinate
        let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 300, longitudinalMeters: 300)
        self.mapView.setRegion(coordinateRegion, animated: true)
        
        if self.isTimerRunning == true {
            if self.startLocation == nil {
                self.startLocation = locations.first
                let startPoint = MKPointAnnotation()
                startPoint.title = "Inicio"
                startPoint.coordinate = CLLocationCoordinate2D(latitude: (locations.first?.coordinate.latitude)!, longitude: (locations.first?.coordinate.longitude)!)
                self.mapView.addAnnotation(startPoint)
            } else {
                /*if(location.horizontalAccuracy < 20 && location.horizontalAccuracy >= 0 && location.verticalAccuracy < 5) {
                    let lastLocation = locations.last
                    let distance = startLocation.distance(from: lastLocation!)
                    if distance > 0.8 {
                        startLocation = lastLocation
                        distanceTraveled += distance
                        let km = Double(floor(distanceTraveled)/1000)
                        distanceLabel.text = NSString.localizedStringWithFormat("%.3f km", km) as String
                    }
                }*/
                
                for newLocation in locations {
                    if newLocation.horizontalAccuracy < 20 && newLocation.horizontalAccuracy >= 0 && newLocation.verticalAccuracy < 5 {
                        if let previousPoint = locationsHistory.last {
                            self.distanceTraveled += newLocation.distance(from: previousPoint)
                            
                            if self.isPaused == true {
                                var area = [newLocation.coordinate, newLocation.coordinate]
                                let polyline = MKPolyline(coordinates: &area, count: area.count)
                                mapView.addOverlay(polyline)
                                self.isPaused = false
                            } else {
                                var area = [previousPoint.coordinate, newLocation.coordinate]
                                let polyline = MKPolyline(coordinates: &area, count: area.count)
                                mapView.addOverlay(polyline)
                            }
                        }
                        self.locationsHistory.append(newLocation)
                        let km = Double(floor(distanceTraveled)/1000)
                        distanceLabel.text = NSString.localizedStringWithFormat("%.3f km", km) as String
                    }
                }
            }
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
         if (overlay is MKPolyline) {
             let pr = MKPolylineRenderer(overlay: overlay)
             pr.strokeColor = UIColor.red
             pr.lineWidth = 5
             return pr
         } else {
             return MKOverlayRenderer(overlay: overlay)
         }
     }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        return annotationView
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    @IBAction func actionPlay(_ sender: Any) {
        if self.isTimerRunning == true {
            timer.invalidate()
            self.buttonPlay.setBackgroundImage(UIImage(systemName:"play.circle"), for: UIControl.State.normal)
            self.isTimerRunning = false
            self.isPaused = true
        } else {
            runTimer()
            self.buttonPlay.setBackgroundImage(UIImage(systemName:"pause.circle.fill"), for: UIControl.State.normal)
            self.isTimerRunning = true
            startLocation = nil
            stepCounter()
            saved = false
        }
    }
    
    @objc func longPressPlay(){
        if saved == false {
            saveCoreData()
            saved = true
        }
        stopTimer()
        self.buttonPlay.setBackgroundImage(UIImage(systemName:"play.circle"), for: UIControl.State.normal)
        self.isTimerRunning = false
        self.startLocation = nil
        self.distanceTraveled = 0;
        self.distanceLabel.text = "0,000 km"
        self.timeLabel.text = "00:00:00"
        self.rateLabel.text = "0,0 min/km"
        self.steps = 0
        self.cadenceLabel.text = String(self.steps) + " pasos"
        self.rate = 0
        self.mapView.removeOverlays(self.mapView.overlays)
        self.locationsHistory = []
    }
    
    func stopTimer() {
        timer.invalidate()
        self.seconds = 0
        self.timeLabel.text = self.timeString(time: TimeInterval(self.seconds)) //Actualizamos el label.
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.seconds += 1
            self.timeLabel.text = self.timeString(time: TimeInterval(self.seconds)) //Actualizamos el label.
            let min:Double = Double(self.seconds)/60
            let km = Double(floor(self.distanceTraveled)/1000)
            self.rate = Double(min/km)
            self.rateLabel.text = NSString.localizedStringWithFormat("%.1f min/km", self.rate) as String
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func stepCounter(){
        if CMPedometer.isStepCountingAvailable() {
            OperationQueue().addOperation {
                self.pedometer.startUpdates(from: Date()) {
                    (data, error) in
                    OperationQueue.main.addOperation {
                        self.cadenceLabel.text = String((data?.numberOfSteps.stringValue)!) + " pasos"
                    }
                }
            }
        }
    }
    
    func saveCoreData(){
        guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let miContexto = miDelegate.persistentContainer.viewContext
        let history = History(context:miContexto)
        history.date = Date()
        let km = Double(floor(self.distanceTraveled)/1000)
        history.km = km
        history.rate = self.rate
        history.step = Int16(self.steps)
        history.time = Int16(self.seconds)
        
        do {
           try miContexto.save()
        } catch {
           print("Error al guardar el contexto: \(error)")
        }
    }
    
}
