//
//  Status.swift
//  FlameBook
//
//  Created by Joshua Chao on 9/23/16.
//  Copyright © 2016 Joshua Chao. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Status {
    let key: String!
    let content: String!
    let addedByUser: String!
    let itemRef: FIRDatabaseReference?
    
    init (content: String, addedByUser: String, key: String = "") {
        self.key = key
        self.content = content
        self.addedByUser = addedByUser
        itemRef = nil
    }
    
    init (snapshot: FIRDataSnapshot) {
        key = snapshot.key
        itemRef = snapshot.ref
        
        let value = snapshot.value as? NSDictionary
        let statusContent = value?["content"] as? String
        let statusUser = value?["addedByUser"] as? String
        content = statusContent
        addedByUser = statusUser
    }
    
    
    func toAnyObject() -> NSDictionary {
        return ["content": content, "addedByUser": addedByUser] as NSDictionary
    }
}
