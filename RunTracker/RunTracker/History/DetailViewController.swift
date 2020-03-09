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
    
    var seconds = 0
    var distanceTraveled = 0.0
    var rate = 0.0
    var steps = 0
    
    var locationsHistory: [Location] = []
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timeLabel.text = self.timeString(time: TimeInterval(self.seconds))
        self.distanceLabel.text = String(self.distanceTraveled) + " km"
        self.rateLabel.text = NSString.localizedStringWithFormat("%.1f min/km", self.rate) as String
        self.stepsLabel.text = String(self.steps) + " pasos/min"
        
        self.mapView.delegate = self
        self.mapView.showsCompass = true
        self.mapView.showsScale = true
        
        locationsHistory = locationsHistory.sorted(by: { ($0.id < $1.id) })
        
        self.drawOverlays()
    }
    
    func drawOverlays(){
        if var previousLocation = self.locationsHistory.first {
            for location in self.locationsHistory {
                var area:[CLLocationCoordinate2D]
                if location.isPaused == true {
                    let newCLLocation: CLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    area = [newCLLocation.coordinate, newCLLocation.coordinate]
                } else {
                    let previousCLLocation: CLLocation = CLLocation(latitude: previousLocation.latitude, longitude: previousLocation.longitude)
                    let newCLLocation: CLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    area = [previousCLLocation.coordinate, newCLLocation.coordinate]
                }
                let polyline = MKPolyline(coordinates: &area, count: area.count)
                mapView.addOverlay(polyline)
                previousLocation = location
            }
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
}
