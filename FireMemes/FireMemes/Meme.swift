//
//  Meme.swift
//  FireMemes
//
//  Created by Colton Lemmon on 6/5/17.
//  Copyright © 2017 Colton. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import MapKit

class Meme {
    
    let imageData: Data?
    var image: UIImage? { // WTF
        guard let imageData = self.imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    
    let date: Date
    let identifier: String
    let thumbsUp: Int
    let comments: [String]
    let location: CLLocation
    
    init(imageData: Data?, image: UIImage, date: Date, id: String = UUID().uuidString, thumbsUp: Int = 0, comments: [String] = [], location: CLLocation) {
        self.imageData = imageData
        //self.image = image  WTF?
        self.date = date
        self.identifier = id
        self.thumbsUp = thumbsUp
        self.comments = comments
        self.location = location
    }
    
}

extension Meme {
    
    convenience init?(cloudKitRecord: CKRecord) {
        
        guard let photoAsset = cloudKitRecord[Keys.imageData] as? CKAsset else { return nil }
        
        let imageData = try? Data(contentsOf: photoAsset.fileURL)//WTF??
        guard let image = cloudKitRecord[Keys.image] as? UIImage,
            let date = cloudKitRecord[Keys.date] as? Date,
            let id = cloudKitRecord[Keys.identifier] as? String,
            let thumbsUp = cloudKitRecord[Keys.thumbsUp] as? Int,
            let comments = cloudKitRecord[Keys.comments] as? [String],
            let location = cloudKitRecord[Keys.location] as? CLLocation else { return nil }
        self.init(imageData: imageData, image: image, date: date, id: id, thumbsUp: thumbsUp, comments: comments, location: location)
    }
    
    fileprivate var temporaryPhotoURL: URL { //WTF
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        
        try? imageData?.write(to: fileURL, options: [.atomic])
        
        return fileURL
    }
    
    var cloudKitRecord: CKRecord {
        let recordID = CKRecordID(recordName: identifier)
        let record = CKRecord(recordType: Keys.meme, recordID: recordID)
        record[Keys.imageData] = CKAsset(fileURL: temporaryPhotoURL)
        //record[Keys.image] = image as CKRecordValue WTF
        record[Keys.date] = date as CKRecordValue
        record[Keys.identifier] = identifier as CKRecordValue
        record[Keys.thumbsUp] = thumbsUp as CKRecordValue
        record[Keys.comments] = comments as CKRecordValue
        record[Keys.location] = location as CKRecordValue
        
        return record
    }
    
}
