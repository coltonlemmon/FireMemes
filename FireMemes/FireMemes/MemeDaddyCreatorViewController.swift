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
    
    @IBOutlet weak var memeImageView: MemeImageView!
    
    @IBOutlet weak var pickingButton: UIButton!
    
    @IBOutlet weak var postMemeButton: UIButton!
    @IBOutlet weak var downloadMemeButton: UIButton!
    @IBOutlet weak var addTextButton: UIButton!
    
    @IBOutlet weak var updateTextButton: UIButton!
    
    //MARK: picker properties 
    
    let textPicker = UIPickerView()
    
    let colorData = ["red", "green", "blue", "white", "black"]
    let fontData = ["Impact", "American", "Avenir", "Helvetica"]
    
    var pickerData: [[String]] = [[]]
    
    //MARK: - Location Properties
    
    var myLocation: CLLocation?
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
                setupButtons()
        
        pickerData = [colorData, fontData]
        
        hideKeyboardWhenTappedAround()
        
        postMemeButton.layer.cornerRadius = 15
        updateTextButton.layer.cornerRadius = 15
        
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
        
        updateTextButton.layer.borderWidth = 0.5
        downloadMemeButton.layer.borderWidth = 0.5
        addTextButton.layer.borderWidth = 0.5
        
        postMemeButton.layer.borderColor = UIColor.red.cgColor
        updateTextButton.layer.borderColor = UIColor.red.cgColor
        addTextButton.layer.borderColor = UIColor.red.cgColor
        downloadMemeButton.layer.borderColor = UIColor.red.cgColor
        
        postMemeButton.layer.cornerRadius = 15
        updateTextButton.layer.cornerRadius = 15
        downloadMemeButton.layer.cornerRadius = 15
        addTextButton.layer.cornerRadius = 15
    }
    

    //MARK: ACTIONS
    @IBAction func pickImage(_ sender: Any) {
        getImage()
    }
    
    @IBAction func postMeme(_ sender: Any) {
        guard (memeImageView.image != nil) else { return }
        self.locationManager.requestLocation()
        let image = memeImageView.makeImageFromView()
        
        guard let location = myLocation else { return }
        guard let meme = MemeController.shared.createMeme(image: image, location: location) else { return }
        MemeController.shared.postMeme(meme: meme)
        
        let nc = navigationController
        nc?.popViewController(animated: true)
    }
    
    
    @IBAction func updateText(_ sender: Any) {
        
        guard (memeImageView.image != nil) else { return }
     
        guard let font = getFontFromPicker() else { return }
        let color = getColorFromPicker()
        
        memeImageView.updateTextForMemeWith(font: font, color: color)

    }
    
    @IBAction func downloadMemeToPhone(_ sender: Any) {
        guard memeImageView.image != nil else { return }
        
        let image = memeImageView.makeImageFromView()
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    @IBAction func addText(_ sender: Any) {
        guard memeImageView.image != nil else { return }
        
        memeImageView.addText()
    }
    
    //MARK: END ACTIONS

    func getImage() {
        
        pickingButton.isHidden = true
        //Create an Instance of Image Picker Controller
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
        guard let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        self.memeImageView.set(image: originalImage, and: self.view.layer.bounds.size)
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)

    }
    
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
        case "blue":
            return .blue
        case "green":
            return .green
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
        
        return NSAttributedString(string: componentString, attributes: [NSForegroundColorAttributeName: UIColor.white])
    }
    
    func setupPicker() {
        
        textPicker.tintColor = .white
        self.view.addSubview(textPicker)
        
        textPicker.translatesAutoresizingMaskIntoConstraints = false
        
        let pickerBottom = NSLayoutConstraint(item: textPicker, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        let topPicker = NSLayoutConstraint(item: textPicker, attribute: .top, relatedBy: .equal, toItem: downloadMemeButton, attribute: .bottom, multiplier: 1, constant: 0)
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























