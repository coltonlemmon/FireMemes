//
//  MemeImageView.swift
//  PinchRecognizerProj
//
//  Created by Gavin Olsen on 6/8/17.
//  Copyright © 2017 Gavin Olsen. All rights reserved.
//

import UIKit

class MemeImageView: UIImageView, UITextFieldDelegate, UIGestureRecognizerDelegate, UITextViewDelegate {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let memeText = UITextField(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
    
    var originalImage = UIImage()
    var viewSize = CGSize()
    
    var touchCount = 0 {
        didSet {
            DispatchQueue.main.async {
                let nc = NotificationCenter.default
                nc.post(name: NSNotification.Name(rawValue: "getImage"), object: nil)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touchCount != 0 else { touchCount += 1; return}
    }
    
    func userDragged(_ gesture: UIPanGestureRecognizer) {
        memeText.center = gesture.location(in: self)
    }
    
    func addTextField() {
        
        hideKeyboardWhenTappedAround()
        
        memeText.delegate = self
        
        memeText.textAlignment = .center
        
        memeText.backgroundColor = .clear
        memeText.text = "spicy meme"
        memeText.font = UIFont(name: "AmericanTypewriter", size: 24)
        memeText.textColor = .red
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(userDragged(_:)))
    
        self.addGestureRecognizer(gesture)
        memeText.isUserInteractionEnabled = true

        self.addSubview(memeText)
    }
    
    func makeImageFromView() -> UIImage {
        
        memeText.tintColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        let image = renderer.image { (ctx) in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
        return image
    }
    
    func set(image: UIImage, and size: CGSize) {
        originalImage = image
        viewSize = size
        self.image = image
        
        
        
        addTextField()
    }
    
    func resetTouchCount() {
        touchCount = 0
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("began")
        memeText.endFloatingCursor()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        memeText.textAlignment = .center
        memeText.endFloatingCursor()
    }
    
    func redrawImageWithTextAt(point: CGPoint) {
        
        self.image = originalImage
        let image = makeImageFromView()
        self.image = image
    }
    
    func updateTextForMemeWith(font: UIFont, color: UIColor) {
        memeText.textColor = color
        memeText.font = font
    }
    
}

extension UIView {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        self.endEditing(true)
    }
}


/*
 
 func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
 
 let textColor = UIColor.blue
 guard let textFont = UIFont(name: "AmericanTypewriter", size: 12) else { return UIImage() }
 
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

 */



















