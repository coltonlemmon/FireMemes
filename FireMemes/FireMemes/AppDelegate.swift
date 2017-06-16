//
//  AppDelegate.swift
//  FireMemes
//
//  Created by Colton Lemmon on 6/5/17.
//  Copyright © 2017 Colton. All rights reserved.
//

import UIKit
import UserNotifications
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Turn Time, battery, cell service white
        UINavigationBar.appearance().barStyle = .blackOpaque
        
//        let unc = UNUserNotificationCenter.current()
//        unc.requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
//            if let error = error {
//                print("Error requesting authorization for notifications: \(error)")
//                return
//            }
//        }
//        UIApplication.shared.registerForRemoteNotifications()
        
        return true
    }
//    
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print("Error registering for remote notifications: \(error)")
//    }
//    
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        MemeController.shared.subscribeToPushNotifications()
//    }
//    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        let VC = ShowMemesTableViewController()
//        MemeController.shared.fetch(VC.mylocation, radiusInMeters: 30000)
//        VC.refreshing()
//        
//    }
//    
//    let locationManager = CLLocationManager()
//    var myLocation: CLLocation?
//        
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if status == .authorizedWhenInUse {
//            locationManager.requestLocation()
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            myLocation = location
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Error with locationManager: \(error.localizedDescription)")
//    }
//    

}

