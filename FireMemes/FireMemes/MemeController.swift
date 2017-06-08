//
//  MemeController.swift
//  FireMemes
//
//  Created by Colton Lemmon on 6/5/17.
//  Copyright © 2017 Colton. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CloudKit

class MemeController {
    
    //MARK: - Shared Instance
    
    static let shared = MemeController()
    
    //MARK: - Internal Properties
    
    let cloudKitManager = CloudKitManager()
    
    var memes: [Meme] = [] {
        didSet {
            DispatchQueue.main.async {
                let nc = NotificationCenter.default
                nc.post(name: Keys.notification, object: self)
            }
        }
    }
    
    //MARK: - CRUD
    
    func createMeme(image: UIImage, location: CLLocation) -> Meme {
        
        guard let data = UIImagePNGRepresentation(image) else { return Meme(imageData: nil, image: image, location: location) }
        
        let meme = Meme(imageData: data, image: image, location: location)
        return meme
    }
    
    func postMeme(meme: Meme) {
        self.saveUsingCloudKit(record: CKRecord(meme)) { (error) in
            if let error = error {
                print("Error saving to cloudKit \(error.localizedDescription)")
            }
        }
    }
    
    func addCommentToMeme(meme: Meme, comment: String) {
        meme.comments.append(comment)
        let record = CKRecord(meme)
        record[Keys.comments] = meme.comments as CKRecordValue
        
        cloudKitManager.modifyRecords([record], perRecordCompletion: nil) { (records, error) in
            if let error = error {
                print("Error adding comment: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - CloudKit Stuff
    func fetch(_ location: CLLocation, radiusInMeters: CLLocationDistance) {
        let radiusInKilometers = radiusInMeters / 1000.0
        let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(%K,%@) < %F", "Location", location, radiusInKilometers)
        cloudKitManager.fetchRecordsWithType(Keys.meme, predicate: locationPredicate, recordFetchedBlock: { (record) in
            guard let meme = Meme(record: record) else { return }
            
            if self.TodayIsCloseEnoughTo(memeDate: meme.date) {
                self.memes.append(meme)
            } else {
                self.delete(meme)
            }
            
        }) { (_, error) in
            if let error = error {
                print("Error fetching meme: \(error.localizedDescription)")
            }
        }
    }
    
    func TodayIsCloseEnoughTo(memeDate: Date) -> Bool {
        let today = Date()
        let memeLife = memeDate.timeIntervalSince(today)
        let dayLimitForMeme = 1
        
        //check if the meme's life span is less than your limit, 
        // if it is less, this meme will be added to the
        // array of memes, otherwise, it won't
        
        if memeLife < Double(60 * 60 * 24 * dayLimitForMeme) {
            return true
        } else {
            return false
        }
    }
    
    func delete(_ meme: Meme) {
        guard let recordID = meme.ckRecordID else { return }
        cloudKitManager.deleteRecordWithID(recordID) { (recordID, error) in
            if error != nil {
                print(error ?? "something went wrong")
            }
        }
    }
}

protocol CloudKitSync {
    init?(record: CKRecord)
    
    var ckRecordID: CKRecordID? { get set }
    var recordType: String { get }
}

extension CloudKitSync {
    
    var isSynced: Bool {
        return ckRecordID != nil
    }
    
    var ckReference: CKReference? {
        guard let recordID = ckRecordID else { return nil }
        return CKReference(recordID: recordID, action: .none)
    }
}

extension MemeController {
    func saveUsingCloudKit(record: CKRecord, completion: @escaping (Error?) -> Void) {
        cloudKitManager.saveRecord(record) { (record, error) in
            completion(error)
        }
    }
}

