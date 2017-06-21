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
    
    let imageData: Data?
    var image: UIImage? { // WTF
        guard let imageData = self.imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    //for verification of flags, to keep
    //the user in check...
    
    var memeOwner: User?
    var memeOwnerReference: CKReference?
    var flagCount: Int
    var isBanned = false
    
    //gavin added
    var usersThatLikedRefs: [CKReference] = []
    var usersThatFlaggedRefs: [CKReference] = []
    var likers: [CKReference]?
    
    let date: Date
    let identifier: String
    var thumbsUp: Int
    var comments: [String]
    let location: CLLocation
    var ckRecordID: CKRecordID?
    var ckReference: CKReference?
    var recordType: String { return Keys.meme }
    
    init(imageData: Data?, image: UIImage?, date: Date = Date(), id: String = UUID().uuidString, thumbsUp: Int = 0, comments: [String] = [], location: CLLocation, creatorRef: CKReference?, flagCount: Int = 0, memeOwner: User?, isBanned: Bool = false, usersThatLiked: [CKReference] = [], usersThatFlagged: [CKReference] = [], likers: [CKReference]) {
        self.imageData = imageData
        self.date = date
        self.identifier = id
        self.thumbsUp = thumbsUp
        self.comments = comments
        
        self.memeOwner = memeOwner
        self.isBanned = isBanned
        
        self.likers = likers
        
        self.memeOwnerReference = creatorRef
        
        self.flagCount = flagCount
        
        self.location = location
        
        self.usersThatLikedRefs = usersThatLiked
        self.usersThatFlaggedRefs = usersThatFlagged
    }
    
    convenience required init?(record: CKRecord) {
        guard let imageAsset = record[Keys.imageData] as? CKAsset else { return nil }
        guard let imageData = try? Data(contentsOf: imageAsset.fileURL) else { return nil }
        let image = UIImage(data: imageData)
        
        guard let date = record[Keys.date] as? Date,
            let id = record[Keys.identifier] as? String,
            let thumbsUp = record[Keys.thumbsUp] as? Int,
            let comments = record[Keys.comments] as? [String],
            let flagCount = record[Keys.flag] as? Int,
            let isBanned = record[Keys.isMemeBaned] as? Bool,
            let memeOwner = record[Keys.owner] as? CKReference,
            let location = record[Keys.location] as? CLLocation,
            let usersThatLiked = record[Keys.usersThatLiked] as? [CKReference],
            let usersThatFlagged = record[Keys.usersThatFlagged] as? [CKReference],
            let likers = record[Keys.liker] as? [CKReference] else { return nil }
        
        self.init(imageData: imageData, image: image, date: date, id: id, thumbsUp: thumbsUp, comments: comments, location: location, creatorRef: memeOwner, flagCount: flagCount, memeOwner: nil, isBanned: isBanned, usersThatLiked: usersThatLiked, usersThatFlagged: usersThatFlagged, likers: likers)
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
        
        guard let owner = meme.memeOwner else { return }

        let userRecordID = owner.ckRecordID ?? CKRecord(owner).recordID
        
        var url: URL = URL(fileURLWithPath: "")
        if let image = meme.image {
            if let data = UIImagePNGRepresentation(image) {
                let fileName = getDocumentsDirectory().appendingPathComponent(".png")
                try? data.write(to: fileName)
                url = fileName
            }
        }
        
        self[Keys.liker] = meme.likers as CKRecordValue?
        
        self[Keys.isMemeBaned] = meme.isBanned as CKRecordValue?
        self[Keys.flag] = meme.flagCount as CKRecordValue?
        self[Keys.owner] = CKReference(recordID: userRecordID, action: .deleteSelf)
        self[Keys.date] = meme.date as CKRecordValue?
        self[Keys.identifier] = meme.identifier as CKRecordValue?
        self[Keys.thumbsUp] = meme.thumbsUp as CKRecordValue?
        self[Keys.comments] = meme.comments as CKRecordValue?
        self[Keys.location] = meme.location as CKRecordValue?
        
        self[Keys.usersThatLiked] = meme.usersThatLikedRefs as CKRecordValue
        self[Keys.usersThatFlagged] = meme.usersThatFlaggedRefs as CKRecordValue
        
        self[Keys.imageData] = CKAsset(fileURL: url)
    }
    
}

//MARK: - Equatable
extension Meme: Equatable {}
func ==(lhs: Meme, rhs: Meme) -> Bool {
    if lhs.cloudKitRecordID != rhs.cloudKitRecordID { return false }
    return true
}
