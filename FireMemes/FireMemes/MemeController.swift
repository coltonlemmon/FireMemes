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
    
    var likers: [CKReference] = [] {
        didSet {
            DispatchQueue.main.async {
                let nc = NotificationCenter.default
                nc.post(name: Keys.likerNotification, object: self)
            }
        }
    }
    
    //MARK: - CRUD
    func createMeme(image: UIImage, location: CLLocation) -> Meme? {
        
        guard let user = UserController.shared.currentUser else { return nil }
        guard let data = UIImagePNGRepresentation(image) else { return nil }
        
        guard let userID = UserController.shared.currentUser?.ckRecordID else { return nil }
        let userReference = CKReference(recordID: userID, action: .deleteSelf)
        
        let meme = Meme(imageData: data, image: image, location: location, creatorRef: user.ckReference, memeOwner: user, likers: [userReference])
        return meme
    }
    
    func postMeme(meme: Meme) {
        self.saveUsingCloudKit(record: CKRecord(meme)) { (error) in
            if let error = error {
                print("Error saving to cloudKit \(error.localizedDescription)")
            }
        }
        //memes.insert(meme, at: 0)
    }
    
    func addCommentToMeme(meme: Meme, comment: String) {
        meme.comments.append(comment)
        guard let cloudKitRecordID = meme.cloudKitRecordID else { return }
        cloudKitManager.fetchRecord(withID: cloudKitRecordID) { (record, error) in
            guard let record = record else { return }
            record[Keys.comments] = meme.comments as CKRecordValue
            self.cloudKitManager.modifyRecords([record], perRecordCompletion: nil) { (records, error) in
                if let error = error {
                    print("Error adding comment: \(error.localizedDescription)")
                }
                DispatchQueue.main.async {
                    let nc = NotificationCenter.default
                    nc.post(name: Keys.notification, object: self)
                }
            }
        }
        
    }
    
//    func addUpvoteToMeme(meme: Meme) {
//        meme.thumbsUp += 1
//        guard let cloudKitRecordID = meme.cloudKitRecordID else { return }
//        cloudKitManager.fetchRecord(withID: cloudKitRecordID) { (record, error) in
//            guard let record = record else { return }
//            record[Keys.thumbsUp] = meme.thumbsUp as CKRecordValue
//            self.cloudKitManager.modifyRecords([record], perRecordCompletion: nil, completion: { (records, error) in
//                if let error = error {
//                    print("Error upvoting meme: \(error.localizedDescription)")
//                }
//                DispatchQueue.main.async {
//                    let nc = NotificationCenter.default
//                    nc.post(name: Keys.notification, object: self)
//                }
//            })
//        }
//    }
    
    func upvoteMeme(meme: Meme) {
        guard var likers = meme.likers else { return }
        guard let likerID = UserController.shared.currentUser?.ckRecordID else { return }
        let likerReference = CKReference(recordID: likerID, action: .deleteSelf)
        guard let cloudKitRecordID = meme.cloudKitRecordID else { return }

        likers.append(likerReference)
        self.likers = likers
        
        cloudKitManager.fetchRecord(withID: cloudKitRecordID) { (record, error) in
            guard let record = record else { return }
            record[Keys.liker] = likers as CKRecordValue
            self.cloudKitManager.modifyRecords([record], perRecordCompletion: nil, completion: { (records, error) in
                if let error = error {
                    print("Error liking meme: \(error.localizedDescription)")
                }
                DispatchQueue.main.async {
                    let nc = NotificationCenter.default
                    nc.post(name: Keys.notification, object: self)
                }
            })
        }
    }
    
    func removeUpvote(meme: Meme) {
        guard var likers = meme.likers else { return }
        guard let likerID = UserController.shared.currentUser?.ckRecordID else { return }
        let likerReference = CKReference(recordID: likerID, action: .deleteSelf)
        guard let cloudKitRecordID = meme.cloudKitRecordID else { return }
        
        guard let index = likers.index(of: likerReference) else { return }
        likers.remove(at: index)
        self.likers = likers
        
        cloudKitManager.fetchRecord(withID: cloudKitRecordID) { (record, error) in
            guard let record = record else { return }
            record[Keys.liker] = likers as CKRecordValue
            self.cloudKitManager.modifyRecords([record], perRecordCompletion: nil, completion: { (records, error) in
                if let error = error {
                    print("Error removing upvote: \(error.localizedDescription)")
                }
                DispatchQueue.main.async {
                    let nc = NotificationCenter.default
                    nc.post(name: Keys.notification, object: self)
                }
            })
        }
    }
    
//    func removeUpvoteToMeme(meme: Meme) {
//        if meme.thumbsUp >= 1 {
//            meme.thumbsUp -= 1
//            guard let cloudKitRecordID = meme.cloudKitRecordID else { return }
//            cloudKitManager.fetchRecord(withID: cloudKitRecordID, completion: { (record, error) in
//                guard let record = record else { return }
//                record[Keys.thumbsUp] = meme.thumbsUp as CKRecordValue
//                self.cloudKitManager.modifyRecords([record], perRecordCompletion: nil, completion: { (records, error) in
//                    if let error = error {
//                        print("Error removing upvote: \(error.localizedDescription)")
//                    }
//                    DispatchQueue.main.async {
//                        let nc = NotificationCenter.default
//                        nc.post(name: Keys.notification, object: self)
//                    }
//                })
//            })
//        }
//    }
    
    //MARK: - CloudKit Stuff
    func fetch(_ location: CLLocation, radiusInMeters: CGFloat, completion: @escaping ([Meme]) -> Void) {
        let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(Location,%@) < %f", location, radiusInMeters)
        cloudKitManager.fetchRecordsWithType(Keys.meme, predicate: locationPredicate, recordFetchedBlock: { (record) in }) { (_, records, error) in

            guard let records = records else { completion([]); return }
            
            for record in records {
                
                guard let meme = Meme(record: record) else { return }
            
                if self.TodayIsCloseEnoughTo(memeDate: meme.date) {
                    if !self.memes.contains(meme) {
                        self.memes.append(meme)
                        completion(self.memes)
                    }
                    self.memes.sort { $0.date > $1.date }
                } else {
                    self.delete(meme)
                    guard let index = self.memes.index(of: meme) else { return }
                    self.memes.remove(at: index)
                }
            }
            
            if let error = error {
                print("Error fetching meme: \(error.localizedDescription)")
            }
            completion([])
        }
    }
    
    //MARK: FLAGGING THE MEME
    //all you have to do is call this function, and it'll take care of
    //flagging the meme, deleting it if it has 3+ flags, and deleting the user
    // if they have 3+ flags too.
    
    func flag(_ meme: Meme) {
        meme.flagCount += 1
        UserController.shared.currentUser?.flagCount += 1
        CloudKitManager.shared.modifyFlagCount(meme)
    }
    
    func userLiked(_ meme: Meme) {
        guard var newLikers = meme.likers else { return }
        guard let ownerID = meme.memeOwner?.ckRecordID else { return }
        let ownerReference = CKReference(recordID: ownerID, action: .deleteSelf)
        guard let likerID = UserController.shared.currentUser?.ckRecordID else { return }
        let likerReference = CKReference(recordID: likerID, action: .deleteSelf)
        
        if !newLikers.contains(likerReference) {
            newLikers.append(likerReference)
            cloudKitManager.increase(meme, with: newLikers)
        } else if likerReference == ownerReference {
            var checker = 0
            for liker in newLikers {
                if liker == ownerReference {
                    checker += 1
                }
            }
            if checker == 1 {
                newLikers.append(ownerReference)
                cloudKitManager.increase(meme, with: newLikers)
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
        
        if memeLife > Double(-60 * 60 * 24 * dayLimitForMeme) {
            return true
        } else {
            return false
        }
    }
    
    func delete(_ meme: Meme) {
        guard let recordID = meme.cloudKitRecordID else { return }
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

//MARK: - Subscriptions

//extension MemeController {
//    
//    func subscribeToPushNotifications(completion: @escaping ((_ success: Bool, Error?) -> Void) = { _, _ in }) {
//        let predicate = NSPredicate(value: true)
//        
//        cloudKitManager.subscribe(Keys.meme, predicate: predicate, subscriptionID: "allMemes", contentAvailable: true, alertBody: "New Meme Posted!", options: .firesOnRecordCreation) { (subscription, error) in
//            let success = subscription != nil
//            completion(success, error)
//        }
//    }
//}

