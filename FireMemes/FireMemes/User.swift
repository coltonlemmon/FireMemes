//
//  User.swift
//  FireMemes
//
//  Created by Gavin Olsen on 6/12/17.
//  Copyright © 2017 Colton. All rights reserved.
//

import Foundation
import CloudKit

class User: CloudKitSync {
    
    static let flagCountKey = "FlagCount"
    static let isBannedKey = "UserBanned"
    static let typeKey = "FireMemeUser"
    
    var ckRecordID: CKRecordID?
    var ckReference: CKReference?
    var recordType: String {
        return User.typeKey
    }
    var flagCount: Int
    var isBanned: Bool = false
    
    init(flagCount: Int = 0, isBanned: Bool = false, recordID: CKRecordID) {
        
        self.flagCount = flagCount
        self.isBanned = isBanned
        self.ckRecordID = recordID
    }
    
    convenience required init?(record: CKRecord) {
        guard let flagCount = record[User.flagCountKey] as? Int, let isBanned = record[User.isBannedKey] as? Bool else { return nil }
        self.init(flagCount: flagCount, isBanned: isBanned, recordID: record.recordID)
    }
    
}

extension CKRecord {
    
    convenience init(_ user: User) {
        
        let recordID = CKRecordID(recordName: UUID().uuidString)
        
        self.init(recordType: User.typeKey, recordID: recordID)
        
        self[User.flagCountKey] = user.flagCount as CKRecordValue?
        self[User.isBannedKey] = user.isBanned as CKRecordValue?
        
    }
    
    
}
