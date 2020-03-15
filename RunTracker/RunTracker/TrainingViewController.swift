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
    
    // MARK: - Outlets
    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var buttonStop: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var cadenceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Variables
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
    var isPaused = false
    
    // MARK: - Location Variables
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    private var locationsHistory: [CLLocation] = []
    private var locationsIsPaused: [Bool] = []
    
    // MARK: - View Controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonPlay.tintColor = UIColor.init(red: 30/255, green: 160/255, blue: 0, alpha: 1)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressPlay))
        longPress.minimumPressDuration = 1.5
        self.buttonStop.addGestureRecognizer(longPress)
        
        self.view.addSubview(self.mapView)
        self.view.addSubview(self.buttonPlay)
        self.view.addSubview(self.buttonStop)
        self.view.insertSubview(self.buttonPlay, aboveSubview: self.mapView)
        self.view.insertSubview(self.buttonStop, aboveSubview: self.mapView)
        
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
    
    // MARK: - Location Manager Delegate
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
                self.locationsHistory.append(self.startLocation)
                self.locationsIsPaused.append(self.isPaused)
            } else {
                for newLocation in locations {
                    if newLocation.horizontalAccuracy < 20 && newLocation.horizontalAccuracy >= 0 && newLocation.verticalAccuracy < 5 {
                        if let previousPoint = locationsHistory.last {

                            self.locationsIsPaused.append(self.isPaused)
                            var area:[CLLocationCoordinate2D]
                            if self.isPaused == true {
                                area = [newLocation.coordinate, newLocation.coordinate]
                                self.isPaused = false
                            } else {
                                area = [previousPoint.coordinate, newLocation.coordinate]
                                self.distanceTraveled += newLocation.distance(from: previousPoint)
                            }
                            let polyline = MKPolyline(coordinates: &area, count: area.count)
                            mapView.addOverlay(polyline)
                        }
                        self.locationsHistory.append(newLocation)
                        let km = Double(floor(distanceTraveled)/1000)
                        distanceLabel.text = NSString.localizedStringWithFormat("%.3f", km) as String
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // MARK: - Map View Delegate
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
    
    // MARK: - Actions
    @IBAction func actionPlay(_ sender: Any) {
        if self.isTimerRunning == true {
            timer.invalidate()
            self.buttonPlay.setBackgroundImage(UIImage(systemName:"play.circle.fill"), for: UIControl.State.normal)
            self.buttonPlay.tintColor = UIColor.init(red: 30/255, green: 160/255, blue: 0, alpha: 1)
            self.buttonStop.isHidden = false
            self.isTimerRunning = false
            self.isPaused = true
        } else {
            runTimer()
            self.buttonPlay.setBackgroundImage(UIImage(systemName:"pause.circle.fill"), for: UIControl.State.normal)
            self.buttonPlay.tintColor = UIColor.orange
            self.buttonStop.isHidden = true
            self.isTimerRunning = true
            stepCounter()
            saved = false
        }
        self.buttonPlay.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)

        UIView.animate(withDuration: 2.0, delay: 0,
                                    usingSpringWithDamping: CGFloat(0.20),
                                    initialSpringVelocity: CGFloat(6.0),
                                    options: UIView.AnimationOptions.allowUserInteraction,
                                    animations: {
                                        self.buttonPlay.transform = CGAffineTransform.identity
            },
                                   completion: { Void in()  }
        )
    }
    
    // MARK: - Methods
    @objc func longPressPlay(){
        
        self.buttonStop.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)

        UIView.animate(withDuration: 1.0, delay: 0,
                                    usingSpringWithDamping: CGFloat(0.20),
                                    initialSpringVelocity: CGFloat(6.0),
                                    options: UIView.AnimationOptions.allowUserInteraction,
                                    animations: {
                                        self.buttonStop.transform = CGAffineTransform.identity
            },
                                   completion: { Void in(self.buttonStop.isHidden = true)  }
        )
        if saved == false {
            saveCoreData()
            saved = true
        }
        stopTimer()
        self.buttonPlay.setBackgroundImage(UIImage(systemName:"play.circle.fill"), for: UIControl.State.normal)
        self.buttonPlay.tintColor = UIColor.init(red: 30/255, green: 160/255, blue: 0, alpha: 1)
        self.isTimerRunning = false
        self.startLocation = nil
        self.distanceTraveled = 0;
        self.distanceLabel.text = "0,000"
        self.timeLabel.text = "00:00:00"
        self.rateLabel.text = "0,0"
        self.steps = 0
        self.cadenceLabel.text = String(self.steps)
        self.rate = 0
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.locationsHistory = []
        self.locationsIsPaused = []
        self.isPaused = false
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
            self.rateLabel.text = NSString.localizedStringWithFormat("%.1f", self.rate) as String
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
                        let min:Double = Double(self.seconds)/60
                        self.cadenceLabel.text = String((data?.numberOfSteps.doubleValue)!/min)
                    }
                }
            }
        }
    }
    
    // MARK: - Core Data
    func saveCoreData(){
        guard let miDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let miContexto = miDelegate.persistentContainer.viewContext
        let history = History(context:miContexto)
        history.date = Date()
        history.km = Double(floor(self.distanceTraveled)/1000)
        history.rate = self.rate
        history.step = Int16(self.steps)
        history.time = Int16(self.seconds)
        
        var idLocation = 0
        for data in self.locationsHistory {
            let location = Location(context: miContexto)
            location.latitude = data.coordinate.latitude
            location.longitude = data.coordinate.longitude
            location.id = Int16(idLocation)
            location.isPaused = self.locationsIsPaused[idLocation]
            
            idLocation += 1
            
            location.history = history
            history.addToLocations(location)
            history.user = UserSingleton.userSingleton
            UserSingleton.userSingleton.addToHistories(history)
        }
        do {
           try miContexto.save()
        } catch {
           print("Error al guardar el contexto: \(error)")
        }
    }
    
}
