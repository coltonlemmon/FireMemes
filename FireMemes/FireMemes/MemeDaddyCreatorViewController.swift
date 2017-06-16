//
//  ViewController.swift
//  PinchRecognizerProj
//
//  Created by Gavin Olsen on 6/8/17.
//  Copyright © 2017 Gavin Olsen. All rights reserved.
//

import UIKit
import CoreLocation

class MemeDaddyCreatorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var memeImageView: MemeImageView!
    @IBOutlet weak var postMemeButton: UIButton!
    @IBOutlet weak var addTextButton: UIButton!
    @IBOutlet weak var fireView: UIView!
    @IBOutlet weak var biggerFireView: FireAnimation!
    
    //MARK: picker properties 
    
    let textPicker = UIPickerView()
    
    let colorData = ["black", "white", "red", "orange", "yellow", "green", "cyan", "blue", "purple", "magenta", "gray"]
    let fontData = ["Impact", "American", "Avenir", "Helvetica"]
    
    var pickerData: [[String]] = [[]]
    
    //MARK: - Location Properties
    
    var myLocation: CLLocation?
    var locationManager = CLLocationManager()

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                setupButtons()
        
        let fireAnimation = FireAnimation()
        
        fireView = fireAnimation
        
        biggerFireView.isHidden = true
        
        pickerData = [colorData, fontData]
        
        hideKeyboardWhenTappedAround()
        
        postMemeButton.layer.cornerRadius = 15
        postMemeButton.titleLabel?.alpha = 0.7
        postMemeButton.layer.borderWidth = 1
        postMemeButton.layer.borderColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0).cgColor
        
        addTextButton.layer.cornerRadius = 10
        addTextButton.titleLabel?.alpha = 0.7
        addTextButton.layer.borderWidth = 1
        addTextButton.layer.borderColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0).cgColor
        
        textPicker.delegate = self
        textPicker.dataSource = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        setupPicker()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(getImage), name: NSNotification.Name(rawValue: "getImage"), object: nil)
        
    }
    
    func setupButtons() {
        postMemeButton.layer.borderWidth = 2
        
        addTextButton.layer.borderWidth = 0.5
        
        postMemeButton.layer.borderColor = UIColor.red.cgColor
        addTextButton.layer.borderColor = UIColor.red.cgColor
        
        postMemeButton.layer.cornerRadius = 15
        addTextButton.layer.cornerRadius = 15
    }
    

    //MARK: ACTIONS
    
    var fireAnimationForPicker = FireAnimationForPicker()
    
    @IBAction func postMeme(_ sender: Any) {
        guard (memeImageView.image != nil) else { return }
        self.locationManager.requestLocation()
        let image = memeImageView.makeImageFromView()
        
        guard let location = myLocation else { return }
        guard let meme = MemeController.shared.createMeme(image: image, location: location) else { return }
        MemeController.shared.postMeme(meme: meme)
        
        biggerFireView.isHidden = false
        //timerAction()
        
        let nc = navigationController
        nc?.popViewController(animated: true)
    }
    
    var timer: Timer!
    func timerAction() {
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(endOfWork), userInfo: nil, repeats: true)
    }
    func endOfWork() {
        let nc = navigationController
        nc?.popViewController(animated: true)
        timer.invalidate()
        timer = nil
    }

    @IBAction func addText(_ sender: Any) {
        guard memeImageView.image != nil else { return }
        memeImageView.addText()
    }
    
    //Allow user to select image by tapping on the ImageView
    @IBAction func selectImage(_ sender: UITapGestureRecognizer) {
        getImage()
    }
    
    //MARK: END ACTIONS

    //MARK: - Image picker methods
    
    func getImage() {
     
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        //Create an action sheet
        let actionSheet =  UIAlertController(title: "Photo", message: "Choose Source", preferredStyle: .actionSheet)
        
        //Add camera option to the actionSheet
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            
            //Source type
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                //Choose source type
                imagePicker.sourceType = .camera
                //Allow editing of image
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                print("Camera not available")
            }
        }))
        
        //Add Photo Library option to actionSheet
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            //Choose source Type
            imagePicker.sourceType = .photoLibrary
            //Allow editing of image
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        //Add cancel option to actionSheet
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let originalImage = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        self.memeImageView.set(image: originalImage, and: self.view.layer.bounds.size)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: -  Other Picker Methods
    
    func getFontFromPicker() -> UIFont? {
        
        let int = textPicker.selectedRow(inComponent: 1)
        let font = fontData[int]
        
        let fontSize = CGFloat(24)
        
        switch font {
        case "Impact":
            return UIFont(name: "HelveticaNeue-CondensedBlack", size: fontSize)
        case "American":
            return UIFont(name: "AmericanTypewriter", size: fontSize)
        case "Avenir":
            return UIFont(name: "AvenirNext-HeavyItalic", size: fontSize)
        case "Helvetica":
            return UIFont(name: "HelveticaNeue-Bold", size: fontSize)
        default:
            return UIFont(name:  "HelveticaNeue-CondensedBlack", size: fontSize)
        }
    }
    
    func getColorFromPicker() -> UIColor {
        let int = textPicker.selectedRow(inComponent: 0)
        let color = colorData[int]
        switch color {
        case "red":
            return .red
        case "orange":
            return .orange
        case "yellow":
            return .yellow
        case "blue":
            return .blue
        case "green":
            return .green
        case "cyan":
            return .cyan
        case "purple":
            return .purple
        case "magenta":
            return .magenta
        case "gray":
            return .gray
        case "black":
            return .black
        case "white":
            return .white
        default:
            return .darkText
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }

}

extension MemeDaddyCreatorViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return pickerData.count }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return pickerData[component].count}
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { return pickerData[component][row] }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let pickerComponent = pickerData[component]
        let componentString = pickerComponent[row]
        
        var color: UIColor = .darkText
        let fontSize: CGFloat = 24
        var font = UIFont(name:  "HelveticaNeue-CondensedBlack", size: fontSize)!
        
        switch component {
        case 0:
            let pickerComponent = pickerData[component]
            let componentString = pickerComponent[row]
            
            switch componentString {
            case "red":
                color = .red
            case "orange":
                color = .orange
            case "yellow":
                color = .yellow
            case "blue":
                color = .blue
            case "green":
                color = .green
            case "cyan":
                color = .cyan
            case "purple":
                color = .purple
            case "magenta":
                color = .magenta
            case "gray":
                color = .gray
            case "black":
                color = .black
            case "white":
                color = .white
            default:
                color = .darkText
            }
        case 1:
            let pickerComponent = pickerData[component]
            let componentString = pickerComponent[row]
            
            switch componentString {
            case "Impact":
                font = UIFont(name: "HelveticaNeue-CondensedBlack", size: fontSize)!
            case "American":
                font = UIFont(name: "AmericanTypewriter", size: fontSize)!
            case "Avenir":
                font = UIFont(name: "AvenirNext-HeavyItalic", size: fontSize)!
            case "Helvetica":
                font = UIFont(name: "HelveticaNeue-Bold", size: fontSize)!
            default:
                font = UIFont(name:  "HelveticaNeue-CondensedBlack", size: fontSize)!
            }
        default:
            break
        }
        
        return NSAttributedString(string: componentString, attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName: font])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let color = getColorFromPicker()
        let font = getFontFromPicker()
        memeImageView.updateTextForMemeWith(font: font, color: color)
    }
    
    func setupPicker() {
        
        textPicker.tintColor = .white
        self.view.addSubview(textPicker)
        
        textPicker.translatesAutoresizingMaskIntoConstraints = false
        
        let pickerBottom = NSLayoutConstraint(item: textPicker, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 0.8, constant: 0)
        let topPicker = NSLayoutConstraint(item: textPicker, attribute: .top, relatedBy: .equal, toItem: addTextButton, attribute: .bottom, multiplier: 1, constant: 0)
        let leadPicker = NSLayoutConstraint(item: textPicker, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        let trailPicker = NSLayoutConstraint(item: textPicker, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        
        self.view.addConstraints([pickerBottom, topPicker, leadPicker, trailPicker])
    }
    
    func showBannedAlert() {
        let alertController = UIAlertController(title: "you've been banned", message: "nobody likes your memes", preferredStyle: .alert)
        let dismissActioin = UIAlertAction(title: "bummer", style: .default, handler: nil)
        alertController.addAction(dismissActioin)
        present(alertController, animated: true, completion: nil)
    }
}

//MARK: - Location Manager Delegate Methods
extension MemeDaddyCreatorViewController: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
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
        print("Error getting location to create meme: \(error.localizedDescription)")
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

