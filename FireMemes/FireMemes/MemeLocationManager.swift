//
//  MemeLocationManager.swift
//  FireMemes
//
//  Created by Colton Lemmon on 6/9/17.
//  Copyright © 2017 Colton. All rights reserved.
//

import Foundation
import MapKit

class MemeLocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = MemeLocationManager()
    
    let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    
    func getCurrentLocation(_ completion: ((_ location: CLLocation?) -> Void)?) {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
        guard let userLocation = userLocation else { return }
        completion?(userLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            userLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error with locationManager: \(error.localizedDescription)")
    }
}
