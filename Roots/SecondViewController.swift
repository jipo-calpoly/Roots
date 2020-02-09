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
    let regionRadius: Double = 1000
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        self.getDirections()
    }
    
    @IBAction func goButtonTouched(_ sender: Any) {
        searchTextField.resignFirstResponder()
        print(searchTextField.text)
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchTextField.text!, completionHandler: {(placemarks, error) -> Void in
        if((error) != nil){
           print("Error", error)
        }
        if let placemark = placemarks?.first {
            
           let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
            
            self.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinates, addressDictionary: placemark.addressDictionary as! [String : Any]))
            
            self.getDirections()
       }
            
            
            //self.getDirections();
         })
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
        let locationManager = CLLocationManager()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
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
    
    func getCoordinate( addressString : String,
            completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                        
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
                
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
}
