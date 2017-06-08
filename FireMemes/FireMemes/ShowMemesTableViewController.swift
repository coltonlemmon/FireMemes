//
//  ShowMemesTableViewController.swift
//  FireMemes
//
//  Created by Jose Melendez on 6/7/17.
//  Copyright © 2017 Colton. All rights reserved.
//

import UIKit
import MapKit

class ShowMemesTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    //MARK: - Internal Properties
    var locationManager = CLLocationManager()
    var myLocation: CLLocation?
    
    func fetch() {
        guard let myLocation = myLocation else { return }
        MemeController.shared.fetch(myLocation, radiusInMeters: 500) // We can change radius
    }

    
    func refreshing() {
        tableView.reloadData()
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetch()
        tableView.reloadData()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(refreshing), name: Keys.notification, object: nil)
        tableView.delegate = self
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memeFeed", for: indexPath)
        
        

        return cell
    }
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

}

//MARK: - Location manager delegate functions

extension ShowMemesTableViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            myLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error with locationManager: \(error.localizedDescription)")
    }
    
}

