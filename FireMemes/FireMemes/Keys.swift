//
//  Keys.swift
//  FireMemes
//
//  Created by Colton Lemmon on 6/5/17.
//  Copyright © 2017 Colton. All rights reserved.
//

import Foundation

enum Keys {
    
    //MARK: - General
    
    static let notification = Notification.Name("memeNotification")
    
    //MARK: - Meme
    
    static let meme = "Meme"
    static let imageData = "ImageData"
    static let image = "Image"
    static let date = "Date"
    static let identifier = "Identifier"
    static let thumbsUp = "ThumbsUp"
    static let comments = "Comments"
    static let location = "Location"
    
    //MARK: - User
    
    static let flagCount = "FlagCount"
    static let isBanned = "UserBanned"
    static let userType = "FireMemeUsers"
}
