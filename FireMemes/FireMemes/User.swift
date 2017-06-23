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
    
    var ckRecordID: CKRecordID?
    var ckReference: CKReference?
    var recordType: String {
        return Keys.userType
    }
    var flagCount: Int
    var isBanned: Bool = false
    
    init(flagCount: Int = 0, isBanned: Bool = false, recordID: CKRecordID) {
        
        self.flagCount = flagCount
        self.isBanned = isBanned
        self.ckRecordID = recordID
    }
    
    convenience required init?(record: CKRecord) {
        guard let flagCount = record[Keys.flagCount] as? Int, let isBanned = record[Keys.isBanned] as? Bool else { return nil }
        self.init(flagCount: flagCount, isBanned: isBanned, recordID: record.recordID)
    }
    
}

extension CKRecord {
    
    convenience init(_ user: User) {
        
        let recordID = CKRecordID(recordName: UUID().uuidString)
        
        self.init(recordType: Keys.userType, recordID: recordID)
        
        user.ckRecordID = recordID
        
        self[Keys.flagCount] = user.flagCount as CKRecordValue?
        self[Keys.isBanned] = user.isBanned as CKRecordValue?
        
    }
    
}
