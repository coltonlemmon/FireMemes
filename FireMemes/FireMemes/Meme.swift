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
    
    let date: Date
    let identifier: String
    var thumbsUp: Int
    var comments: [String]
    let location: CLLocation
    var ckRecordID: CKRecordID?
    var ckReference: CKReference?
    var recordType: String { return Keys.meme }
    
    init(imageData: Data?, image: UIImage?, date: Date = Date(), id: String = UUID().uuidString, thumbsUp: Int = 0, comments: [String] = [], location: CLLocation, creatorRef: CKReference?, flagCount: Int = 0, memeOwner: User?, isBanned: Bool = false) {
        self.imageData = imageData
        self.date = date
        self.identifier = id
        self.thumbsUp = thumbsUp
        self.comments = comments
//        self.comments.append("")
        
        self.memeOwner = memeOwner
        self.isBanned = isBanned
        
        self.memeOwnerReference = creatorRef
        
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
            let flagCount = record[Keys.flag] as? Int,
            let isBanned = record[Keys.isMemeBaned] as? Bool,
            let memeOwner = record[Keys.owner] as? CKReference,
            let location = record[Keys.location] as? CLLocation else { return nil }
        self.init(imageData: imageData, image: image, date: date, id: id, thumbsUp: thumbsUp, comments: comments, location: location, creatorRef: memeOwner, flagCount: flagCount, memeOwner: nil, isBanned: isBanned)
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
        
        self[Keys.isMemeBaned] = meme.isBanned as CKRecordValue?
        self[Keys.flag] = meme.flagCount as CKRecordValue?
        self[Keys.owner] = CKReference(recordID: userRecordID, action: .deleteSelf)
        self[Keys.date] = meme.date as CKRecordValue?
        self[Keys.identifier] = meme.identifier as CKRecordValue?
        self[Keys.thumbsUp] = meme.thumbsUp as CKRecordValue?
        self[Keys.comments] = meme.comments as CKRecordValue?
        self[Keys.location] = meme.location as CKRecordValue?
        self[Keys.imageData] = CKAsset(fileURL: url)
    }
    
}

//MARK: - Equatable
extension Meme: Equatable {}
func ==(lhs: Meme, rhs: Meme) -> Bool {
    //if lhs.date != rhs.date { return false }
    if lhs.identifier != rhs.identifier { return false }
    if lhs.imageData != rhs.imageData { return false }
    if lhs.image != rhs.image { return false }
    if lhs.memeOwnerReference != rhs.memeOwnerReference { return false }
    if lhs.flagCount != rhs.flagCount { return false }
    if lhs.isBanned != rhs.isBanned { return false }
    if lhs.thumbsUp != rhs.thumbsUp { return false }
    if lhs.comments != rhs.comments { return false }
    if lhs.location != rhs.location { return false }
    if lhs.ckRecordID != rhs.ckRecordID { return false }
    if lhs.ckReference != rhs.ckReference { return false }
    if lhs.recordType != rhs.recordType { return false }
    return true
}
