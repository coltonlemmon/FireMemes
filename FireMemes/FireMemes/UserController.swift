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
    
    func checkUser() {
        
        CloudKitManager.shared.fetchCurrentUserRecords(User.typeKey) { (recordID, records, error) in
            if error != nil {
                print("error: \(String(describing: error?.localizedDescription))")
            }
            guard let records = records else { return }
            guard let recordID = recordID else { return }
            
            if let record = records.first {
                let user = User(record: record)
                self.currentUser = user
            } else {
                self.makeUserWith(recordID: recordID)
            }
        }
    }
    
    func makeUserWith(recordID: CKRecordID) {
        let newUser = User(recordID: recordID)
        currentUser = newUser
    }
    
    
    
}











































