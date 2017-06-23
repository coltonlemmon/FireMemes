//
//  MemeImageView.swift
//  PinchRecognizerProj
//
//  Created by Gavin Olsen on 6/8/17.
//  Copyright © 2017 Gavin Olsen. All rights reserved.
//

import UIKit

class MemeImageView: UIImageView, UITextFieldDelegate, UIGestureRecognizerDelegate, UITextViewDelegate {
    
    //MARK: - Internal Properties
    
    let memeText = UITextField(frame: CGRect(x: -200, y: 0, width: 700, height: 30))
    
    var memeTextFields: [UITextField] = []
    
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
    
    //MARK: - Touch Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touchCount != 0 else { touchCount += 1; return}
    }
    
    func userDragged(_ gesture: UIPanGestureRecognizer) {
        var draggedText = UITextField()
        let touchPoint = gesture.location(in: self)
        
        for textField in memeTextFields {
            if textField.center.x + 70 > touchPoint.x && textField.center.x - 70 < touchPoint.x && textField.center.y + 20 > touchPoint.y && textField.center.y - 20 < touchPoint.y {
                draggedText = textField
            }
        }
        
        if draggedText.center.y > self.layer.bounds.maxY {
            draggedText.center = center
        } else if draggedText.center.y <= self.layer.bounds.minY {
            draggedText.center = center
        } else if draggedText.center.x > self.layer.bounds.maxX {
            draggedText.center = center
        } else if draggedText.center.x < self.layer.bounds.minX {
            draggedText.center = center
        } else {
            draggedText.center = gesture.location(in: self)
        }
    }
    
    func userPinched(_ sender: UIPinchGestureRecognizer) {
        guard let transform = sender.view?.transform else { return }
        
        sender.view?.transform = transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
    
    //MARK: - Textfield Methods
    
    func addTextField() {
        contentMode = .scaleToFill
        backgroundColor = .white
        hideKeyboardWhenTappedAround()
        
        memeText.delegate = self
        memeText.textAlignment = .center
        memeText.backgroundColor = .clear
        memeText.text = ""
        memeText.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: 24)
        memeText.textColor = .black
        memeText.isUserInteractionEnabled = true
        
        self.addSubview(memeText)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(userDragged(_:)))
        self.addGestureRecognizer(gesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(userPinched(_:)))
        memeText.addGestureRecognizer(pinchGesture)
        
        memeTextFields.append(memeText)
    }
    
    func addText(with font: UIFont?, color: UIColor?) {
        let newText = UITextField(frame: CGRect(x: -200, y: 0, width: 700, height: 30))
        
        newText.delegate = self
        newText.textAlignment = .center
        newText.backgroundColor = .clear
        newText.text = "Enter text here"
        newText.font = font ?? UIFont(name: "HelveticaNeue-CondensedBlack", size: 24)
        newText.textColor = color ?? .black
        
        self.addSubview(newText)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(userDragged(_:)))
        self.addGestureRecognizer(gesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(userPinched(_:)))
        newText.addGestureRecognizer(pinchGesture)
        memeTextFields.append(newText)
    }
    
    func updateTextForMemeWith(font: UIFont?, color: UIColor?) {
        for textField in memeTextFields {
            textField.textColor = color
            textField.font = font
        }
    }
    
    //MARK: - Textfield delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return true
    }
    
    //MARK: - Image Methods
    
    func makeImageFromView() -> UIImage {
        //takes away the cursor
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

    func redrawImageWithTextAt(point: CGPoint) {
        self.image = originalImage
        let image = makeImageFromView()
        self.image = image
    }

}

//MARK: - HideKeyboard extension

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
