//
//  Database.swift
//  tableViewDemo
//
//  Created by kennyS on 11/12/18.
//  Copyright © 2018 LTT. All rights reserved.
//

import Foundation
import RealmSwift

class Database {
    static let singleton = Database()
    private init() {
        
    }
    
    func createOrUpdate(todoItemValue: String) {
        let realm = try! Realm()
        
        var todoId: Int? = 1
        print(realm.objects(TodoItem.self).count)
        if let lastEntity = realm.objects(TodoItem.self).last {
            print(lastEntity)
            todoId = lastEntity.todoId + 1
        }
        let todoItemEntity = TodoItem()
        todoItemEntity.todoId = todoId!
        todoItemEntity.todoValue = todoItemValue
        
        try! realm.write {
            realm.add(todoItemEntity, update: true )
        }
    }
    
    func fetch() -> Results<TodoItem> {
        let realm = try! Realm()
        
        let todoItemResults = realm.objects(TodoItem.self).sorted(byKeyPath: "createAt")
        return todoItemResults
    }
    
    func softDelete(primaryKey: Int) {
        let realm = try! Realm()
        if let todoItemEntity = realm.object(ofType: TodoItem.self, forPrimaryKey: primaryKey) {
            try! realm.write {
                todoItemEntity.deletedAt = Date()
            }
        }
    }
    
    func delete(primaryKey: Int) {
        let realm = try! Realm()
        
        if let todoItemEntity = realm.object(ofType: TodoItem.self, forPrimaryKey: primaryKey) {
            try! realm.write {
                realm.delete(todoItemEntity)
            }

        }
    }
    
    func isDone(primaryKey: Int) {
        let realm = try! Realm()
        if let todoItemEntity = realm.object(ofType: TodoItem.self, forPrimaryKey: primaryKey) {
            try! realm.write {
                todoItemEntity.isDone = !(todoItemEntity.isDone) 
            }
        }
    }
}
