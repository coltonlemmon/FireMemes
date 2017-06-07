//
//  MemeCreatorViewController.swift
//  fireMemes
//
//  Created by Gavin Olsen on 6/6/17.
//  Copyright © 2017 Colton. All rights reserved.
//

import UIKit

class MemeCreatorViewController: UIViewController {
    
    //MARK: VIEW ISSHHHHH
    //everything in my view!!!
    @IBOutlet weak var memeImageView: UIImageView!
    var memeImage = #imageLiteral(resourceName: "oldMan")
    
    @IBOutlet weak var memeTextField: UITextField!
    
    @IBOutlet weak var vertSlider: UISlider!
    @IBOutlet weak var horSlider: UISlider!
    
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var textPicker: UIPickerView!
    
    let colorData = ["red", "green", "blue", "white", "black"]
    let fontData = ["American", "Avenir", "Helvetica"]
    let fontSizeData = ["200", "100","150","12","24","50"]
    
    var pickerData: [[String]] = [[]]

    
    //MARK: VIEW ISSHHHHH
    //view ish ends

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerData = [colorData, fontData, fontSizeData]
        
        textPicker.delegate = self
        
        vertSlider.isContinuous = false
        horSlider.isContinuous = false
        
        vertSlider.value = Float(memeImage.size.height / 2)
        horSlider.value = Float(memeImage.size.width / 2)
        
        setupView()
        hideKeyboardWhenTappedAround()
    }
    
    //MARK: ACTIONS
    
    
    @IBAction func saveMeme(_ sender: Any) {
        guard let image = memeImageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    @IBAction func updateText(_ sender: Any) {
        updateMeme()
    }
    
    @IBAction func pickImage(_ sender: Any) {
        choosePic()
    }
    
    @IBAction func changeVertSlider(_ sender: UISlider) {
        updateMeme()
    }
    
    @IBAction func changeHorSlider(_ sender: UISlider) {
        updateMeme()
    }
    
    
}

extension MemeCreatorViewController: UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func setupView() {
        
        //set the sliders...
        
        vertSlider.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi * (3/2)))
        //a very poor attempt to increase the sliders width (actually it's height...),
        //but since i just tipped it 90 degrees, it's just
        
        //i'm gonna try to make a constraint from the leading side of 
        //the vert slider to the top of the view, and the trailing to the bottom
        //of the updatebutton
        
        let sliderTop = NSLayoutConstraint(item: vertSlider, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        
        self.view.addConstraints([sliderTop])
        
        
        vertSlider.layer.bounds.size.width = 500
        vertSlider.layer.bounds.size.height = 500

        
        
    }
    
    //MARK: ACTIONS START
    
    func choosePic() {
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
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    
    
    //MARK: ACTIONS BEGIN
    
    func setupConstraints() {
        
        memeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let memeTop = NSLayoutConstraint(item: memeImageView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 70)
        let memeLead = NSLayoutConstraint(item: memeImageView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 30)
        let memeTrail = NSLayoutConstraint(item: memeImageView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        let memeBottom = NSLayoutConstraint(item: memeImageView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 253)
        
        self.view.addConstraints([memeTop, memeLead, memeTrail, memeBottom])
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return pickerData.count }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return pickerData[component].count}
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { return pickerData[component][row] }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        
        self.memeImage = textToImage(drawText: "", inImage: originalImage, atPoint: CGPoint(x: 0, y: 0))
        
        setSliders()
        
        self.memeImageView.image = textToImage(drawText: "", inImage: originalImage, atPoint: CGPoint(x: 0, y: 0))
        
        self.memeImageView.contentMode = UIViewContentMode.scaleAspectFit
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func setSliders() {
        vertSlider.maximumValue = Float(memeImage.size.height)
        horSlider.maximumValue = Float(memeImage.size.width)
    }
    
    //MARK: DRAWING!!!
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        
        let textColor = getColorFromPicker()
        
        guard let textFont = getFontFromPicker() else { return #imageLiteral(resourceName: "oldMan") }
        
        let imageRenderer = UIGraphicsImageRenderer(bounds: CGRect(origin: CGPoint.zero, size: image.size))
        
        var memeText = memeTextField.text
        
        if memeText == "" {
            memeText = text
            
        }
        
        let newImage = imageRenderer.image { (ctx) in
            
            let textFontAttributes = [
                NSFontAttributeName: textFont,
                NSForegroundColorAttributeName: textColor,
                ] as [String : Any]
            image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
            
            let rect = CGRect(origin: point, size: image.size)
            memeText?.draw(in: rect, withAttributes: textFontAttributes)
        }
        
        return newImage
    }
    func resize(image: UIImage) -> UIImage {
        
        let scale = memeImageView.bounds.width / image.size.width
        
        let newWidth = (image.size.width * scale) + 1730
        let newHeight = (image.size.height * scale) + 800
        
        let size = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        UIGraphicsEndImageContext()
        
        return newImage
    }

    func updateMeme() {
        
        let x = CGFloat(horSlider.value)
        let y = CGFloat(vertSlider.value)
        
        var adjustedY = memeImage.size.height - y
        
        //60
        if y < 60 {
            adjustedY = adjustedY - 60
        }
        
        let point = CGPoint(x: x, y: adjustedY)
        let text = "enter meme"
        let image = textToImage(drawText: text, inImage: memeImage, atPoint: point)
        
        memeImageView.image = image
        
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
    
    func getFontFromPicker() -> UIFont? {
        
        let int = textPicker.selectedRow(inComponent: 1)
        let font = fontData[int]
        
        let intt = textPicker.selectedRow(inComponent: 2)
        guard let stringSize = Int(fontSizeData[intt]) else { return UIFont(name: "AmericanTypewriter", size: 24) }
        let size = CGFloat(stringSize)
        
        switch font {
        case "American":
            return UIFont(name: "AmericanTypewriter", size: size)
        case "AvenirNext":
            return UIFont(name: "AvenirNext-HeavyItalic", size: size)
        case "Helvetica":
            return UIFont(name: "Helvetica Bold", size: size)
        default:
            return UIFont(name: "AmericanTypewriter", size: 24)
        }
    }
    
    func getFontSize() -> Int {
        
        
        
        
        return 0
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













