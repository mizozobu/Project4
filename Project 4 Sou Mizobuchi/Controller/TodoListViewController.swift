//
//  TodoListViewController.swift
//  Project 4 Sou Mizobuchi
//
//  Created by user144546 on 12/5/18.
//  Copyright © 2018 IS543. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    let db = TodoDatabase.sharedDB
    var items = [Item]()
    
    private struct StoryBoard {
        static let ItemCellIdentifier = "ItemCellIdentifier"
    }
    
    // Mark - table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items = db.findAllItems()
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.ItemCellIdentifier, for: indexPath)
        cell.textLabel?.text = items[indexPath.row].name
        
        return cell
    }
    
    // Mark - table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = items[indexPath.row].id
        if let i = id {
            do {
                try db.setItemToDone(i)
                items.remove(at: indexPath.row)
                self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: UITableView.RowAnimation.right)
            }
            catch {
                print("Error in set item \(i) to done")
            }
        }
    }



// Mark - helpers
    
}
