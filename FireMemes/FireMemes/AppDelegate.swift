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
}

