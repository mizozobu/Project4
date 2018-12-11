//
//  SqliteService.swift
//  Project 4 Sou Mizobuchi
//
//  Created by user144546 on 12/5/18.
//  Copyright © 2018 IS543. All rights reserved.
//

import Foundation
import GRDB

class TodoDatabase {
    
    // MARK: - Constants
    struct Constant {
        static let fileName = "todo"
        static let fileExtension = "sqlite"
    }
    
    // MARK: - Properties
    var dbQueue: DatabaseQueue!
    
    static let sharedDB = TodoDatabase()
    
    // Mark - Init
    init() {
        do {
            connect()
            try migrator.migrate(dbQueue)
            addItem("Jjjj")
        }
        catch {
            print("DB connection error.")
        }
    }
    
    private func connect() {
        let fileManager = FileManager.default
        let doumentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let destinationPath = doumentDirectoryPath.appendingPathComponent("todo.sqlite")
        let sourcePath = Bundle.main.path(forResource: "todo", ofType: "sqlite")

        if !fileManager.fileExists(atPath: destinationPath) {
            do {
                try fileManager.copyItem(atPath: sourcePath!, toPath: destinationPath)
            }
            catch {
                print("DB already exists")
            }
        }
        
        dbQueue = try? DatabaseQueue(path: destinationPath)
    }
    
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("createItemsTable") { database in
            try database.create(table: Item.databaseTableName) { tableDefinition in
                tableDefinition.column("id", .integer).primaryKey()
                tableDefinition.column("name", .text).notNull().collate(.localizedCaseInsensitiveCompare)
                tableDefinition.column("isDone", .boolean)
            }
        }
        
        return migrator
    }
    
    public func findItemById(_ id: Int64) -> Item {
        do {
            let item = try dbQueue.inDatabase { (db: Database) -> Item in
                let row = try Row.fetchOne(db, "SELECT * FROM \(Item.databaseTableName) WHERE id = ?", arguments: [id], adapter: nil)
                if let returnedRow = row {
                    return Item(row: returnedRow)
                }
                return Item(name: "could not find item")
            }
            return item
        }
        catch {
            return Item(name: "could not find item")
        }
    }
    
    public func findAllItems() -> [Item] {
        do {
            let items = try dbQueue.inDatabase { (db: Database) -> [Item] in
                var items = [Item]()
                let rows = try Row.fetchCursor(db, "SELECT * FROM \(Item.databaseTableName) WHERE isDone = 0")
                while let row = try rows.next() {
                    items.append(Item(row: row))
                }

                return items
            }
            
            return items
        }
        catch {
            return []
        }
    }
    
    public func addItem(_ name: String) {
        do {
            try dbQueue.write { (db: Database) in
                let item = Item(name: name)
                try item.insert(db)
            }
        }
        catch {
            print("could not create \(name)")
        }
    }
    
    public func setItemToDone(_ id: Int64) throws {
        do {
            try dbQueue.write { (db: Database) in
                try db.execute(
                    "UPDATE items SET isDone = 1 WHERE id = ?;",
                    arguments: [id]
                )
            }
        }
        catch {
            throw "could not mark item \(id) as done"
        }
    }
}

extension String: Error {}
