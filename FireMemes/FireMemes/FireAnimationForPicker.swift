//
//  FireAnimationForPicker.swift
//  FireMemes
//
//  Created by Colton Lemmon on 6/14/17.
//  Copyright © 2017 Colton. All rights reserved.
//

import UIKit
import QuartzCore

class FireAnimationForPicker: UIView {
    
    override func didMoveToWindow() {
        createFire()
    }
    
    func createFire() {
        let fireEmitter = CAEmitterLayer()
        fireEmitter.emitterPosition = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)
        fireEmitter.emitterSize = CGSize(width: 1, height: 1)
        fireEmitter.renderMode = kCAEmitterLayerAdditive
        fireEmitter.emitterShape = kCAEmitterLayerLine
        fireEmitter.emitterCells = [createFireCell()]
        
        self.layer.addSublayer(fireEmitter)
    }
    
    func createFireCell() -> CAEmitterCell {
        let fire = CAEmitterCell()
        fire.alphaSpeed = -0.3
        fire.birthRate = 60
        fire.lifetime = 60.0
        fire.lifetimeRange = 0.5
        fire.color = UIColor.init(colorLiteralRed: 0.6, green: 0.15, blue: 0.1, alpha: 0.44).cgColor
        fire.contents = UIImage(named: "fire2")?.cgImage
        fire.emissionLongitude = CGFloat(Double.pi)
        fire.velocity = 80
        fire.velocityRange = 5
        fire.emissionRange = 0.5
        fire.yAcceleration = -200
        fire.scaleSpeed = 0.3
        
        return fire
    }
    
}

