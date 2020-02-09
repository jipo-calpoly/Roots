//
//  SecondViewController.swift
//  roots.us
//
//  Created by Jillian Quinn on 2/8/20.
//  Copyright © 2020 Jillian Quinn. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class RouteViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    //class SecondViewController: UIViewController{
    @IBOutlet weak var searchTextField: UITextField!
    var destination: MKMapItem?
    @IBOutlet weak var routeMap: MKMapView!
    var locationManager: CLLocationManager = CLLocationManager()
    var userLocation: CLLocation?
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        self.getDirections()
        
    }
    
    @IBAction func goButtonTouched(_ sender: Any) {
        searchTextField.resignFirstResponder()
        print(searchTextField.text)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        routeMap.delegate = self
        routeMap.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestLocation()
    }
    func getDirections() {
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        
        if let destination = destination {
            request.destination = destination
        }
        
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        
        directions.calculate(completionHandler: {(response, error) in
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let response = response {
                    self.showRoute(response)
                }
            }
        })
    }
    
    func showRoute(_ response: MKDirections.Response) {
        
        for route in response.routes {
            
            routeMap.addOverlay(route.polyline,
                                level: MKOverlayLevel.aboveRoads)
            
            for step in route.steps {
                print(step.instructions)
            }
        }
        
        if let coordinate = userLocation?.coordinate {
            let region =
                MKCoordinateRegion(center: coordinate,
                                   latitudinalMeters: 2000, longitudinalMeters: 2000)
            routeMap.setRegion(region, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor
        overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        return renderer
    }
}
