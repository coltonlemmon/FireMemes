//
//  UserController.swift
//  FireMemes
//
//  Created by Gavin Olsen on 6/12/17.
//  Copyright © 2017 Colton. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    static let shared = UserController()
    
    var currentUser: User?
    
    func checkUserIn() {
        
        CloudKitManager.shared.fetchCurrentUserRecords(User.typeKey) { (_, records, error) in
            if error != nil {
                print("error: \(String(describing: error?.localizedDescription))")
            }
            
            if let record = records?.first {
                let user = User(record: record)
                self.currentUser = user
            } else {
                self.makeUser()
            }
        }
    }
    
    func makeUser() {
        CloudKitManager.shared.fetchLoggedInUserRecord { (record, error) in
            
            guard let record = record else { return }
            let newUser = User(flagCount: 0, isBanned: false, recordID: record.recordID)
            self.currentUser = newUser
            
            guard let userRecord = newUser.ckRecordID else { return }
            
            let newRecord = CKRecord(recordType: User.typeKey, recordID: userRecord)
            
            CloudKitManager.shared.saveRecord(newRecord, completion: { (record, error) in
                if record == nil || error != nil {
                    print("something went wrong saving the user")
                }
            })
            
        }
    }
    
    
    
    
    
}











































