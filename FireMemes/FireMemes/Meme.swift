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

class Meme: CloudKitSync {
    
    static let ownerKey = "memeOwnerKey"
    static let flagKey = "memeFlagKey"
    static let isMemeBanedKey = "isMemeBannedKey"
    
    let imageData: Data?
    var image: UIImage? { // WTF
        guard let imageData = self.imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    //for verification of flags, to keep
    //the user in check...
    
    var memeOwner: User?
    var memeOwnerID: CKRecordID?
    var flagCount: Int
    var isBanned = false
    
    let date: Date
    let identifier: String
    var thumbsUp: Int
    var comments: [String]
    let location: CLLocation
    var ckRecordID: CKRecordID?
    var ckReference: CKReference?
    var recordType: String { return Keys.meme }
    
    init(imageData: Data?, image: UIImage?, date: Date = Date(), id: String = UUID().uuidString, thumbsUp: Int = 0, comments: [String] = [], location: CLLocation, creatorID: CKRecordID?, flagCount: Int = 0, memeOwner: User?, isBanned: Bool = false) {
        self.imageData = imageData
        self.date = date
        self.identifier = id
        self.thumbsUp = thumbsUp
        self.comments = comments
        self.comments.append("")
        
        self.memeOwner = memeOwner
        self.isBanned = isBanned
        
        self.memeOwnerID = creatorID
        
        self.flagCount = flagCount
        
        self.location = location
    }
    
    convenience required init?(record: CKRecord) {
        guard let imageAsset = record[Keys.imageData] as? CKAsset else { return nil }
        guard let imageData = try? Data(contentsOf: imageAsset.fileURL) else { return nil }
        let image = UIImage(data: imageData)
        
        guard let date = record[Keys.date] as? Date,
            let id = record[Keys.identifier] as? String,
            let thumbsUp = record[Keys.thumbsUp] as? Int,
            let comments = record[Keys.comments] as? [String],
            let flagCount = record[Meme.flagKey] as? Int,
            let isBanned = record[Meme.isMemeBanedKey] as? Bool,
            let memeOwner = record[Meme.ownerKey] as? CKRecordID,
            let location = record[Keys.location] as? CLLocation else { return nil }
        self.init(imageData: imageData, image: image, date: date, id: id, thumbsUp: thumbsUp, comments: comments, location: location, creatorID: memeOwner, flagCount: flagCount, memeOwner: nil, isBanned: isBanned)
        cloudKitRecordID = record.recordID
    }
    
    fileprivate var temporaryPhotoURL: URL { //WTF
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
        
        
        try? imageData?.write(to: fileURL, options: [.atomic])
        
        return fileURL
    }
    
    
    var cloudKitRecordID: CKRecordID?
}

extension CKRecord {
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    convenience init(_ meme: Meme) {
        
        let recordID = CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: Keys.meme, recordID: recordID)
        meme.ckRecordID = recordID
        
        guard let creatorID = meme.memeOwner?.ckRecordID else {return}
        
        var url: URL = URL(fileURLWithPath: "")
        if let image = meme.image {
            if let data = UIImagePNGRepresentation(image) {
                let fileName = getDocumentsDirectory().appendingPathComponent(".png")
                try? data.write(to: fileName)
                url = fileName
            }
        }
        
        self[Meme.isMemeBanedKey] = meme.isBanned as CKRecordValue?
        self[Meme.flagKey] = meme.flagCount as CKRecordValue?
        self[Meme.ownerKey] = creatorID as? CKRecordValue
        self[Keys.date] = meme.date as CKRecordValue?
        self[Keys.identifier] = meme.identifier as CKRecordValue?
        self[Keys.thumbsUp] = meme.thumbsUp as CKRecordValue?
        self[Keys.comments] = meme.comments as CKRecordValue?
        self[Keys.location] = meme.location as CKRecordValue?
        self[Keys.imageData] = CKAsset(fileURL: url)
    }
    
}
