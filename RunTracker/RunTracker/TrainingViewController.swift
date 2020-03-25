//
//  TrainingViewController.swift
//  RunTracker
//
//  Created by Julia García Martínez on 17/02/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import AVFoundation
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
    @IBOutlet weak var hrmLabel: UILabel!
    
    // MARK: - Variables
    var timer = Timer()
    var seconds = 0
    var seconds_acumulated = 0
    var seconds_paused = 0
    var isTimerRunning = false
    var startLocation: CLLocation!
    var distanceTraveled: Double = 0
    var distance_acumulated: Double = 0
    var pedometer = CMPedometer()
    var activityManager = CMMotionActivityManager()
    var steps = 0
    var rate: Double = 0
    var saved = false
    var isPaused = false
    var optionsValues: OptionsValues?
    var playStop = true
    
    // MARK: - Location Variables
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
        return manager
    }()
    private var locationsHistory: [CLLocation] = []
    private var locationsIsPaused: [Bool] = []
    private var locationsDate: [Date] = []
    
    // MARK: - View Controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressStop))
        longPress.minimumPressDuration = 2
        
        self.buttonPlay.tintColor = UIColor.MyPalette.spanishGreen
        
        self.buttonStop.addGestureRecognizer(longPress)
        self.buttonStop.addTarget(self, action: Selector(("startStopAnimation")), for: .touchDown)
        self.buttonStop.addTarget(self, action: Selector(("pauseStopAnimation")), for: .touchUpInside)
        
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
        
        self.locationManager.delegate = self
        self.locationManager.showsBackgroundLocationIndicator = true
        self.locationManager.allowsBackgroundLocationUpdates = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.optionsValues = OptionsValues()
        setAccuracyGPS()
    }
    
    // MARK: - Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager.startUpdatingLocation()
                self.mapView.showsUserLocation = true
                
            default:
                self.locationManager.stopUpdatingLocation()
                self.mapView.showsUserLocation = false
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
                self.locationsDate.append(Date())
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
                                self.distance_acumulated += newLocation.distance(from: previousPoint)
                                //Notificar distancia
                                self.notifyIntervals()
                            }
                            let polyline = MKPolyline(coordinates: &area, count: area.count)
                            mapView.addOverlay(polyline)
                        }
                        self.locationsHistory.append(newLocation)
                        self.locationsDate.append(Date())
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
        
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        
        if self.isTimerRunning == true {
            timer.invalidate()
            self.buttonPlay.setBackgroundImage(UIImage(systemName:"play.circle"), for: UIControl.State.normal)
            self.buttonPlay.tintColor = UIColor.MyPalette.spanishGreen
            self.buttonStop.isHidden = false
            self.isTimerRunning = false
            self.isPaused = true
        } else {
            runTimer()
            self.buttonPlay.setBackgroundImage(UIImage(systemName:"pause.circle"), for: UIControl.State.normal)
            self.buttonPlay.tintColor = UIColor.orange
            self.buttonStop.isHidden = true
            self.isTimerRunning = true
            stepCounter()
            saved = false
        }
        self.buttonPlay.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        self.buttonStop.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)

        UIView.animate(withDuration: 2.0, delay: 0,
                                    usingSpringWithDamping: CGFloat(0.20),
                                    initialSpringVelocity: CGFloat(6.0),
                                    options: UIView.AnimationOptions.allowUserInteraction,
                                    animations: {
                                        self.buttonPlay.transform = CGAffineTransform.identity
                                        self.buttonStop.transform = CGAffineTransform.identity
            },
                                   completion: { Void in()  }
        )
    }
    
    // MARK: - Methods
    @objc func startStopAnimation() {
        UIView.animate(withDuration: 2,
        animations: {
            self.buttonStop.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        },
        completion: { _ in
            if self.playStop == true {
                UIView.animate(withDuration: 0.5, delay: 0,
                                            usingSpringWithDamping: CGFloat(0.20),
                                            initialSpringVelocity: CGFloat(6.0),
                                            options: UIView.AnimationOptions.allowUserInteraction,
                                            animations: {
                                                self.buttonStop.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                                            },
                                            completion: { _ in
                                                self.buttonStop.transform = CGAffineTransform.identity
                                                self.buttonStop.isHidden = true
                                            }
                )
            } else {
                self.buttonStop.transform = CGAffineTransform.identity
            }
        })
    }
    
    @objc func pauseStopAnimation() {
        self.buttonStop.layer.removeAllAnimations()
        self.view.layer.removeAllAnimations()
        self.view.layoutIfNeeded()
        self.playStop = false
    }
    
    @objc func longPressStop(){
        if saved == false {
            saveCoreData()
            saved = true
        }
        stopTimer()
        resetTraining()
    }
    
    func resetTraining() {
        self.buttonPlay.setBackgroundImage(UIImage(systemName:"play.circle"), for: UIControl.State.normal)
        self.buttonPlay.tintColor = UIColor.MyPalette.spanishGreen
        self.isTimerRunning = false
        self.startLocation = nil
        self.distanceTraveled = 0
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
        self.locationsDate = []
        self.isPaused = false
        self.playStop = true
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
            let min: Double = Double(self.seconds)/60
            self.seconds_acumulated += 1
            // Notificar tiempo
            self.notifyIntervals()
            let km = Double(floor(self.distanceTraveled)/1000)
            self.rate = km > 0 ? Double(min/km) : 0
            
            if self.rate <= 0 {
                self.seconds_paused += 1
                self.checkAutopause()
            }
            
            self.rateLabel.text = NSString.localizedStringWithFormat("%.1f", self.rate) as String
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func stepCounter() {
        if CMPedometer.isStepCountingAvailable() {
            OperationQueue().addOperation {
                self.pedometer.startUpdates(from: Date()) {
                    (data, error) in
                    self.steps = Int((data?.numberOfSteps.doubleValue)!)
                    let min: Double = Double(self.seconds)/60
                    let cadence = Double(self.steps)/min
                    self.checkCadence(cadence)
                    OperationQueue.main.addOperation {
                        self.cadenceLabel.text = String(cadence)
                    }
                }
            }
        }
    }
    
    // MARK: Set options
    func notifyIntervals() {
        if let measure = optionsValues?.getIntervalValues()?.measure {
            if measure == "TIME" {
                if let timeValue = optionsValues?.getIntervalValues()?.measureValue {
                    if timeValue == Int(seconds_acumulated/60) {
                        seconds_acumulated = 0
                        playNotificationSound(useNotifications: optionsValues?.getIntervalValues()?.useNotifications, sound: optionsValues?.getIntervalValues()?.idSound)
                    }
                }
            } else if measure == "DISTANCE" {
                if let distanceValue = optionsValues?.getIntervalValues()?.measureValue {
                    if distanceValue == Int(distance_acumulated) {
                        distance_acumulated = 0
                        playNotificationSound(useNotifications: optionsValues?.getIntervalValues()?.useNotifications, sound: optionsValues?.getIntervalValues()?.idSound)
                    }
                }
            }
        }
    }
    
    func checkCadence(_ cadence: Double) {
        if let cadenceValue = optionsValues?.getCadenceValues().cadence {
            if cadenceValue > Int(cadence) {
                playNotificationSound(useNotifications: optionsValues?.getCadenceValues().useNotifications, sound: optionsValues?.getCadenceValues().idSound)
            }
        }
    }
    
    func checkAutopause() {
        if let autopause = optionsValues?.getAutopauseValue() {
            if autopause {
                if Int(seconds_paused/60) >= OptionsValues.MAX_MINS_PAUSED {
                    stopTimer()
                    self.seconds_paused = 0
                    resetTraining()
                }
            }
        }
    }
    
    func playNotificationSound(useNotifications: Bool?, sound: SystemSoundID?) {
        if let u = useNotifications {
            if u {
                if let s = sound {
                    AudioServicesPlaySystemSound(s)
                }
            } else {
                AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
            }
        }
    }
    
    func setAccuracyGPS() {
        switch optionsValues?.getGPSAccuracy() {
            case AccuracyGPS.GPS_OPTIMUM.raw():
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                break
            case AccuracyGPS.GPS_MEDIUM.raw():
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                break
            case AccuracyGPS.GPS_LOW.raw():
                locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                break
            default:
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                break
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
            location.date = self.locationsDate[idLocation]
            
            idLocation += 1
            
            location.history = history
            history.addToLocations(location)
            history.user = UserSingleton.userSingleton.user
            UserSingleton.userSingleton.user.addToHistories(history)
        }
        do {
           try miContexto.save()
        } catch {
           print("Error al guardar el contexto: \(error)")
        }
    }
    
}
