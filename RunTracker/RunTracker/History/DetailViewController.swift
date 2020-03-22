//
//  DetailViewController.swift
//  RunTracker
//
//  Created by Pablo López Iborra on 07/03/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DetailViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    // MARK: - Variables
    var seconds = 0
    var distanceTraveled = 0.0
    var rate = 0.0
    var steps = 0
    var locationsHistory: [Location] = []
    var maxSpeed = 0.0
    var actualSpeed = 0.0
    
    // MARK: - View Controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timeLabel.text = self.timeString(time: TimeInterval(self.seconds))
        self.distanceLabel.text = String(self.distanceTraveled)
        self.rateLabel.text = NSString.localizedStringWithFormat("%.1f", self.rate) as String
        self.stepsLabel.text = String(self.steps)
        
        self.mapView.delegate = self
        self.mapView.showsCompass = true
        self.mapView.showsScale = true
        
        locationsHistory = locationsHistory.sorted(by: { ($0.id < $1.id) })
        
        self.calculateMaxSpeed()
        self.drawOverlays()
    }
    
    // MARK: - Methods
    func calculateMaxSpeed() {
        if var previousLocation = self.locationsHistory.first {
            for location in self.locationsHistory {
                if location != self.locationsHistory[self.locationsHistory.count-1] {
                    let timeDiference = location.date?.timeIntervalSince(previousLocation.date!)
                    let hours = ((timeDiference!/60)/60)
                    
                    let newCLLocation: CLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    let previousCLLocation: CLLocation = CLLocation(latitude: previousLocation.latitude, longitude: previousLocation.longitude)
                    
                    let distanceDiference = newCLLocation.distance(from: previousCLLocation)
                    let km = Double(floor(distanceDiference)/1000)
                    
                    if maxSpeed < (km/hours) {
                        self.maxSpeed = km/hours
                        print("Max: " + String(self.maxSpeed))
                    }
                }
                previousLocation = location
            }
        }
    }
    
    func drawOverlays(){
        if var previousLocation = self.locationsHistory.first {
            var polylines:[MKOverlay] = []
            for location in self.locationsHistory {
                var area:[CLLocationCoordinate2D]
                var newCLLocation: CLLocation
                var previousCLLocation: CLLocation
                if location.isPaused == true {
                    newCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    previousCLLocation = CLLocation(latitude: 0, longitude: 0)
                    area = [newCLLocation.coordinate, newCLLocation.coordinate]
                } else {
                    previousCLLocation = CLLocation(latitude: previousLocation.latitude, longitude: previousLocation.longitude)
                    newCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    area = [previousCLLocation.coordinate, newCLLocation.coordinate]
                }
                
                if location != self.locationsHistory[self.locationsHistory.count-1] {
                    let timeDiference = location.date?.timeIntervalSince(previousLocation.date!)
                    let hours = ((timeDiference!/60)/60)
                    
                    var distanceDiference = 0.0
                    if location.isPaused != true {
                        distanceDiference = previousCLLocation.distance(from: newCLLocation)
                    }
                    let km = Double(floor(distanceDiference)/1000)
                    
                    self.actualSpeed = km/hours
                    print(self.actualSpeed)
                }
                let polyline = CustomPolyline(coordinates: area, count: area.count)

                if self.actualSpeed >= self.maxSpeed * 3/4 {
                    polyline.color = UIColor.red
                } else if self.actualSpeed >= self.maxSpeed * 2/4 {
                    polyline.color = UIColor.orange
                } else if self.actualSpeed >= self.maxSpeed * 1/4 {
                    polyline.color = UIColor.yellow
                } else {
                    polyline.color = UIColor.green
                }
                
                polylines.append(polyline)
                previousLocation = location
            }
            mapView.addOverlays(polylines)
            
            let centerLocation = CLLocationCoordinate2D(latitude: self.locationsHistory.first!.latitude, longitude: self.locationsHistory.first!.longitude)

            let viewRegion = MKCoordinateRegion(center: centerLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(viewRegion, animated: false)
            
            let startAnnotation = self.addAnnotation(title: "Inicio", subtitle: "", latitude: locationsHistory.first!.latitude, longitude: locationsHistory.first!.longitude)
            _ = self.addAnnotation(title: "Final", subtitle: "", latitude: locationsHistory.last!.latitude, longitude: locationsHistory.last!.longitude)
            
            self.mapView.selectAnnotation(startAnnotation, animated: true)
        }
    }
    
    func addAnnotation(title:String, subtitle:String, latitude:Double, longitude:Double) -> MKAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.mapView.addAnnotation(annotation)
        return annotation
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    // MARK: - Map View Delegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if (overlay is MKPolyline) {
            let pr = MKPolylineRenderer(overlay: overlay)
            let overlayColor = overlay as? CustomPolyline
            pr.strokeColor = overlayColor?.color
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
}
