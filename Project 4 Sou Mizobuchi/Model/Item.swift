//
//  Item.swift
//  Project 4 Sou Mizobuchi
//
//  Created by user144546 on 12/5/18.
//  Copyright © 2018 IS543. All rights reserved.
//

import Foundation
import GRDB

class Item : Record {
    
    // Mark - Table name
    override class var databaseTableName: String {
        return "items"
    }
    
    // Mark - Property
    var id: Int64?
    var name: String
    var isDone: Bool = false
    
    // Mark - Init
    init(name: String) {
        self.name = name
        super.init()
    }
    
    required init(row: Row) {
        id = row["id"]
        name = row["name"]
        isDone = row["isDone"]
        super.init(row: row)
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["name"] = name
        container["isDone"] = isDone
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
