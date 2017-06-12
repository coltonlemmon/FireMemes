//
//  ShowMemesTableViewController.swift
//  FireMemes
//
//  Created by Jose Melendez on 6/7/17.
//  Copyright © 2017 Colton. All rights reserved.
//

import UIKit
import MapKit
import Social

class ShowMemesTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    
    
    //Side menu constraint
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    let test = UIButton()
    
    @IBOutlet weak var tableView: UITableView!
    
    //Button that segues user to editing screen
    @IBOutlet weak var createButtonClick: UIButton!
    //Loading Animation
    @IBOutlet weak var loadingAnimationView: LoadingAnimation!

    //MARK: - Internal Properties
    var locationManager = CLLocationManager()
    var myLocation: CLLocation?
    
    func fetch() {
        
        guard let myLocation = myLocation else { return }
        MemeController.shared.fetch(myLocation, radiusInKilometers: 500) // We can change radius
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
        
        tableView.isHidden = true
        view.backgroundColor = UIColor.gray
        loadingAnimationView.backgroundColor = UIColor.gray
        
        // Location Services
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    
        tableView.reloadData()
        
        // Notification Center
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(refreshing), name: Keys.notification, object: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //Custom button for Make a Meme button
        createButtonClick.layer.cornerRadius = 7
        createButtonClick.layer.backgroundColor = UIColor(red:52/255 , green: 152/255, blue: 219/255, alpha: 0.8).cgColor
        createButtonClick.layer.borderWidth = 2
        createButtonClick.layer.borderColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0).cgColor
        
        //Swipe right gesture 
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightGesture(swipe:)))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(rightSwipe)
        
        
        
    }
    
    //viewWillApear
    override func viewWillAppear(_ animated: Bool) {
        
        //Hided navigation bar
        self.navigationController?.isNavigationBarHidden = false
        //Set navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
    }
    

   
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MemeController.shared.memes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "memeFeed", for: indexPath) as? MemeTableViewCell else { return UITableViewCell() }

        let meme = MemeController.shared.memes.reversed()[indexPath.row]
        
        // Loading Animation
        loadingAnimationView.isHidden = true
        tableView.isHidden = false
        cell.updateViews(meme: meme)
        cell.delegate = self
        
        
        return cell
    }
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

}

//MARK: - Location manager delegate functions

extension ShowMemesTableViewController: CLLocationManagerDelegate, MemeTableViewCellDelegate {
    
    //Swipe right gesture regonizer, Hides the comment section when user swipes right
    func swipeRightGesture(swipe: UISwipeGestureRecognizer) {
        switch swipe.direction.rawValue {
        case 1:
            trailingConstraint.constant = -310
            UIView.animate(withDuration: 0.6, animations: {
                self.view.layoutIfNeeded()
            })

        default:
            break
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            myLocation = location
            fetch()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error with locationManager: \(error.localizedDescription)")
    }
    
    //FacebookShare
    func facebookClicked(_ sender: MemeTableViewCell, image: UIImage) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
            let fbShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            fbShare.setInitialText("The worlds greatest Meme!")
            fbShare.add(image)
            
            self.present(fbShare, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //TwitterShare
    func twitterClicked(_ sender: MemeTableViewCell, image: UIImage) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            
            let tweetShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            self.present(tweetShare, animated: true, completion: nil)
            tweetShare.setInitialText("Amazing Meme Alert!")
            tweetShare.add(image)
            
        } else {
            
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to tweet.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MessageShare
    func messageClicked(_ sender: MemeTableViewCell, image: UIImage) {
        let image = image
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare,
                                                              applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        self.present(activityViewController,animated: true,completion: nil)
    }
    //Comment clicked 
    func commentClicked(_ sender: MemeTableViewCell) {
        
        trailingConstraint.constant = 0
        UIView.animate(withDuration: 0.6, animations: {
            self.view.layoutIfNeeded()
        })

    }
}

