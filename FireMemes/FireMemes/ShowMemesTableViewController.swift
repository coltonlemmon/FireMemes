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

class ShowMemesTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    var meme = MemeController.shared.memes
    var destinationVC: CommentsViewController?
    
    //MARK: - Outlets
    
    @IBOutlet weak var containerTrailingConstant: NSLayoutConstraint!
    
    //Show memes table view
    @IBOutlet weak var tableView: UITableView!
    
    //Button that segues user to editing screen
    @IBOutlet weak var createButtonClick: UIButton!
    
    //Loading Animation
    @IBOutlet weak var loadingAnimationView: LoadingAnimation!
    @IBOutlet weak var loadingMemesLabel: UILabel!
    
    //MARK: - Pull to Refresh
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ShowMemesTableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        refreshControl.backgroundColor = .white
        refreshControl.tintColor = .clear
        refreshControl.clipsToBounds = true
        let box = CGRect(x: self.view.layer.bounds.midX - 15, y: 15, width: 30, height: 30)
        var fireAnimation = FireAnimation(frame: box)
        //refreshControl.attributedTitle = NSAttributedString(string: "Loading Fresh Memes")
        fireAnimation.backgroundColor = .white
        refreshControl.addSubview(fireAnimation)
        return refreshControl
    }()
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.requestLocation()
        didFetch = false
        fetch()
        refreshing()
        timerAction()
    }
    
    var timer: Timer!
    func timerAction() {
        timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(endOfWork), userInfo: nil, repeats: true)
    }
    func endOfWork() {
        refreshControl.endRefreshing()
        timer.invalidate()
        timer = nil
    }

    //MARK: - Internal Properties
    var locationManager = CLLocationManager()
    var myLocation: CLLocation?
    
    //for fetching
    var didFetch: Bool = false
    
    @IBOutlet weak var makeAMemeButton: UIButton!
    
    func fetch() {
        guard let myLocation = myLocation else { return }
        MemeController.shared.fetch(myLocation, radiusInMeters: 30000)
        didFetch = true
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
        
        setupView()
        
        UserController.shared.checkUserIn()
        
        tableView.isHidden = true
        view.backgroundColor = UIColor.white
        loadingAnimationView.backgroundColor = UIColor.white
        tableView.backgroundColor = .white
        
        // Location Services
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    
        tableView.reloadData()
        
        // Pull to Refresh
        self.tableView.addSubview(self.refreshControl)
        
        // Notification Center
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(refreshing), name: Keys.notification, object: nil)
        
        //Table View Delegates
        tableView.delegate = self
        tableView.dataSource = self
       
        //Custom button for Make a Meme button
        createButtonClick.layer.cornerRadius = 7
        createButtonClick.layer.backgroundColor = UIColor(red:255/255 , green: 194/255, blue: 13/255, alpha: 0.8).cgColor
        createButtonClick.layer.borderWidth = 2
        createButtonClick.layer.borderColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0).cgColor
        
        //Swipe right gesture
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightGesture(swipe:)))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(rightSwipe)
        
    }
    
    //viewWillApear
    override func viewWillAppear(_ animated: Bool) {
        //Set navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 255/255, green: 194/255, blue: 13/255, alpha: 1.0)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    var comments = [String]()
    
    //IB-Actions
    @IBAction func addCommentClicked(_ sender: Any) {
        
    }
  
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MemeController.shared.memes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "memeFeed", for: indexPath) as? MemeTableViewCell else { return UITableViewCell() }
        
        let meme = MemeController.shared.memes[indexPath.row]
        
        // Loading Animation
        loadingAnimationView.isHidden = true
        loadingMemesLabel.isHidden = true
        tableView.isHidden = false
        cell.updateViews(meme: meme, hasBeenUpvoted: nil)
        cell.delegate = self
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentSegue" {
            destinationVC = segue.destination as? CommentsViewController
        }
    }
    
    func setupView() {
        makeAMemeButton.layer.cornerRadius = 15
        makeAMemeButton.layer.borderWidth = 1
        makeAMemeButton.layer.borderColor = UIColor.red.cgColor
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}

//MARK: MemeTableViewCellDelegate Methods

extension ShowMemesTableViewController: MemeTableViewCellDelegate {

    //Swipe right gesture regonizer, Hides the comment section when user swipes right
    func swipeRightGesture(swipe: UISwipeGestureRecognizer) {
        switch swipe.direction.rawValue {
        case 1:
            containerTrailingConstant.constant = -310
            UIView.animate(withDuration: 0.6, animations: {
                self.view.layoutIfNeeded()
            })
            
        default:
            break
        }
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
    
    //CommentButton tapped
    func commentButtonTapped(_ sender: MemeTableViewCell){
        
        containerTrailingConstant.constant = 0
        UIView.animate(withDuration: 0.6, animations: {
            self.view.layoutIfNeeded()
            })
        
        guard let newIndexPath = self.tableView.indexPath(for: sender) else { return }
        let meme = MemeController.shared.memes[newIndexPath.row]
        if let destinationVC = self.destinationVC {
            destinationVC.meme = meme
            destinationVC.tableView.reloadData()
        }
        
    }
    
    //UpVote button tapped
    func upVoteButtonTapped(sender: MemeTableViewCell, hasBeenUpvoted: Bool) {
        guard let indexPath = self.tableView.indexPath(for: sender) else { return }
        let meme = MemeController.shared.memes[indexPath.row]
        var localHasBeenUpvoted = hasBeenUpvoted
        var upVoteCount = meme.thumbsUp
        
        if localHasBeenUpvoted == false {
            upVoteCount += 1
            MemeController.shared.addUpvoteToMeme(meme: meme)
            localHasBeenUpvoted = true
            sender.updateViews(meme: meme, hasBeenUpvoted: localHasBeenUpvoted)
        } else {
            if upVoteCount >= 1 {
                upVoteCount -= 1
                MemeController.shared.removeUpvoteToMeme(meme: meme)
                localHasBeenUpvoted = false
                sender.updateViews(meme: meme, hasBeenUpvoted: localHasBeenUpvoted)
            } else {
                MemeController.shared.removeUpvoteToMeme(meme: meme)
                localHasBeenUpvoted = false
                sender.updateViews(meme: meme, hasBeenUpvoted: localHasBeenUpvoted)
            }
        }
    }
    
    //Report button
    func reportButtonTapped(sender: MemeTableViewCell) {
        let alertController = UIAlertController(title: "Report Meme?", message: "Are you sure you want to report this meme?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes Report", style: .default) { (_) in
            guard let indexPath = self.tableView.indexPath(for: sender) else { return }
            let meme = MemeController.shared.memes[indexPath.row]
            MemeController.shared.flag(meme)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

//MARK: - Location Delegate Methods

extension ShowMemesTableViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            myLocation = location
            
            if !didFetch {
                fetch()
                didFetch = true
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error with locationManager: \(error.localizedDescription)")
    }
}
