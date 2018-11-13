//
//  TodoItem.swift
//  tableViewDemo
//
//  Created by kennyS on 11/12/18.
//  Copyright © 2018 LTT. All rights reserved.
//

import Foundation
import RealmSwift

class TodoItem: Object {
    @objc dynamic var todoId: Int = 0
    @objc dynamic var todoValue: String = ""
    @objc dynamic var isDone: Bool = false
    @objc dynamic var createAt: Date? = Date()
    @objc dynamic var updatedAt: Date? = nil
    @objc dynamic var deletedAt: Date? = nil
    
    override static func primaryKey() -> String? {
        return "todoId"
    }
}
