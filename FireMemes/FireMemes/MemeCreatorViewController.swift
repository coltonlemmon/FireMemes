//
//  NewPicViewController.swift
//  memeproj
//
//  Created by Gavin Olsen on 6/5/17.
//  Copyright © 2017 Gavin Olsen. All rights reserved.
//

import UIKit
import CoreImage
import CoreGraphics

class MemeCreatorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var memeTextField: UITextField!
    @IBOutlet weak var downloadButton: UIButton!
    
    @IBOutlet weak var xValue: UISlider!
    @IBOutlet weak var yValue: UISlider!
    
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    
    @IBOutlet weak var testLabel: UILabel!
    
    let textPicker = UIPickerView()
    
    let colorData = ["red", "green", "blue", "white", "black"]
    let fontData = ["AmericanTypewriter", "AvenirNext-HeavyItalic", "Helvetica Bold"]
    let fontSizeData = ["12", "24", "36", "70", "100", "150"]
    
    var pickerData: [[String]] = [[]]
    
    var firstContext: CGContext?
    
    var memeImage = UIImage()
    
    var isImageGiven = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerData = [colorData, fontData]
        
        imageView.image = textToImage(drawText: "", inImage: #imageLiteral(resourceName: "oldMan"), atPoint: CGPoint(x: 0, y: 0))
    
        xValue.maximumValue = 5508
        xValue.minimumValue = 0
        
        yValue.maximumValue = 2848
        yValue.minimumValue = 0
        
        xValue.isContinuous = false
        yValue.isContinuous = false
        
        textPicker.delegate = self
        
        hideKeyboardWhenTappedAround()
        
        setupPicker()
        
    }
    
    //MARK: functions
    
    @IBAction func addPic(_ sender: Any) {
        
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

    //MARK: ACTIONS
    
    @IBAction func saveToPhone(_ sender: Any) {
        
        guard let image = imageView.image else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    @IBAction func changeXValue(_ sender: UISlider) {
        
        xLabel.text = "\(Int(sender.value))"
        
        convertNumbers()
    }
   
    @IBAction func changeYValue(_ sender: UISlider) {
        
        yLabel.text = "\(Int(sender.value))"
        
        convertNumbers()
    }
    
    @IBAction func updateText(_ sender: Any) {
        convertNumbers()
    }
    
    
    //MARK: END ACTIONS
    
    //MARK: DRAWING
    
    func redrawImage() {
        
        let y = CGFloat(yValue.value)
        let x = CGFloat(xValue.value)
        
        let newPoint = CGPoint(x: x, y: y)
        
        memeImage = textToImage(drawText:"aaa", inImage: memeImage, atPoint: newPoint)
        
        imageView.image = memeImage
        
    }
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        
        let textColor = getColorFromPicker()
        guard let textFont = getFontFromPicker() else { return #imageLiteral(resourceName: "oldMan") }
        
        let imageRenderer = UIGraphicsImageRenderer(bounds: CGRect(origin: CGPoint.zero, size: image.size))
        
        let newImage = imageRenderer.image { (ctx) in
        
            let textFontAttributes = [
                NSFontAttributeName: textFont,
                NSForegroundColorAttributeName: textColor,
                ] as [String : Any]
            image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
            
            let rect = CGRect(origin: point, size: image.size)
            text.draw(in: rect, withAttributes: textFontAttributes)
        }
        
        return newImage
    }
    
    func getFontFromPicker() -> UIFont? {
        
        let int = textPicker.selectedRow(inComponent: 1)
        let font = fontData[int]
        
        switch font {
            case "AmericanTypewriter":
                return UIFont(name: "AmericanTypewriter", size: 50)
            case "AvenirNext-HeavyItalic":
                return UIFont(name: "AvenirNext-HeavyItalic", size: 50)
            case "Helvetica Bold":
                return UIFont(name: "Helvetica Bold", size: 50)
            default:
                return UIFont()
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

    func convertNumbers() {
        
        let x = CGFloat(xValue.value)
        let y = CGFloat(yValue.value)
    
        let imageSize = memeImage.size
        
        let scale = view.layer.preferredFrameSize().width / imageSize.width
        
        print(scale)
        
        let testX = x * scale
        let testY = y * scale
        
        let point = CGPoint(x: testX, y: testY)
        
        guard var text = memeTextField.text else { return }
        
        if text == "" {
            text = "enter meme"
        }
        
        let image = textToImage(drawText: text, inImage: memeImage, atPoint: point)
        
        imageView.image = image
        
    }
    
    
}

extension NewPicViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        
        let sizedImage = resize(image: originalImage)
        
        memeImage = sizedImage
        
        self.imageView.image = textToImage(drawText: "", inImage: sizedImage, atPoint: CGPoint(x: 0, y: 0))
        
        self.imageView.contentMode = UIViewContentMode.scaleAspectFit
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func resize(image: UIImage) -> UIImage {
        
        let scale = imageView.bounds.width / image.size.width
        
        let newWidth = (image.size.width * scale) + 1230
        let newHeight = (image.size.width * scale) + 400
        
        let size = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return pickerData.count }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return pickerData[component].count}
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { return pickerData[component][row] }
    
    
    func switchColor() {
        
        
        //will return the color of the picker
    }
    
    func switchFont() {
        
        
        //will return the font of the picker
    }

    
    
    func setContstraintsForYSlider() {
        
        let point = CGPoint(x: 0, y: 0)
        
        yValue.layer.position = point
        
    }
    
    func setupPicker() {
    
        self.view.addSubview(textPicker)
        
        textPicker.translatesAutoresizingMaskIntoConstraints = false
        
        let pickerBottom = NSLayoutConstraint(item: textPicker, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        let topPicker = NSLayoutConstraint(item: textPicker, attribute: .top, relatedBy: .equal, toItem: yValue, attribute: .bottom, multiplier: 1, constant: 0)
        let leadPicker = NSLayoutConstraint(item: textPicker, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        let trailPicker = NSLayoutConstraint(item: textPicker, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        
        self.view.addConstraints([pickerBottom, topPicker, leadPicker, trailPicker])
    
    
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





















