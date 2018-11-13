//
//  TodoViewModel.swift
//  tableViewDemo
//
//  Created by kennyS on 11/12/18.
//  Copyright © 2018 LTT. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

protocol TodoItemPresentable {
    var id: String? { get set }
    var textValue: String? { get }
    var menuItems: [TodoMenuItemViewPresentable]? { get }
    var isDone: Bool? { get set }
}

protocol TodoMenuItemViewPresentable {
    var title: String? { get set }
    var backgroundColor: String? { get }
}

protocol TodoMenuItemViewDelegate {
    func onMenuItemSelected()
}

class TodoMenuItemViewModel: TodoMenuItemViewPresentable, TodoMenuItemViewDelegate {
    
    var title: String?
    var backgroundColor: String?
    weak var parent: TodoItemViewDelegate?
    
    init(parentViewModel: TodoItemViewDelegate) {
        self.parent = parentViewModel
    }
    
    func onMenuItemSelected() {
        
    }
}

class RemoveMenuItemViewModel: TodoMenuItemViewModel {
    override func onMenuItemSelected() {
        print("Remove menu item selected")
        parent?.onRemoveSelected()
    }
}

class DoneMenuItemViewModel: TodoMenuItemViewModel {
    override func onMenuItemSelected() {
        print("Done menu item selected")
        parent?.onDoneSelected()
    }
}

class TodoItemViewModel: TodoItemPresentable {
    var isDone: Bool? = false
    var menuItems: [TodoMenuItemViewPresentable]? = []
    var id: String? = "0"
    var textValue: String?
    weak var parent: TodoViewDelegate?
    
    init(id: String, textValue: String, parentViewmodel: TodoViewDelegate) {
        self.id = id
        self.textValue = textValue
        self.parent = parentViewmodel
        
        let removeItemMenu = RemoveMenuItemViewModel(parentViewModel: self)
        removeItemMenu.title = "Remove"
        removeItemMenu.backgroundColor = "ff0000"
        
        let doneItemMenu = DoneMenuItemViewModel(parentViewModel: self)
        doneItemMenu.title = isDone! ? "UnDone" : "Done"
        doneItemMenu.backgroundColor = "008000"
        menuItems?.append(contentsOf: [removeItemMenu, doneItemMenu])
    }
}

protocol TodoViewDelegate: class {
    func onAddTodoItem()
    func onDeleteTodoItem(todoId: Int)
    func onDoneTodoItem(todoId: Int)
}

protocol TodoItemViewDelegate: class {
    func onItemSelected()
    func onRemoveSelected()
    func onDoneSelected()
}

protocol TodoViewPresentable {
    var newTodoItem: String? { get }
}

class TodoViewModel: TodoViewPresentable {
    var database: Database?
    var newTodoItem: String?
    var items: Variable<[TodoItemViewModel]> = Variable([])
    var notificationToken: NotificationToken? = nil 
    var searchValue: Variable<String>? = Variable("")
    var searchItem: Variable<[TodoItemViewModel]> = Variable([] )
    let disposeBag = DisposeBag()
    
    init() {
        database = Database.singleton
        handleRealm()
        searchValue?.asObservable().subscribe(onNext: { (value) in
            self.items.asObservable().map({ $0.filter({
                if value.isEmpty {
                    return true
                }
                return ($0.textValue?.lowercased().contains(value.lowercased()))!
                })
            }).bind(to: self.searchItem)
                .disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    func handleRealm() {
        
        let todoItemResults = database?.fetch()
        notificationToken = todoItemResults?.observe({ [weak self] (changes: RealmCollectionChange) in
            switch(changes) {
            case .initial:
                todoItemResults?.forEach({ (todoItemEntity) in
                    let todoItemEntity = todoItemEntity
                    let itemIndex = todoItemEntity.todoId
                    let newValue = todoItemEntity.todoValue
                    let newItem = TodoItemViewModel(id: "\(itemIndex)", textValue: newValue, parentViewmodel: self!)
                    self?.items.value.append(newItem)
                    print(self?.database?.fetch())
                })
                break
            case .update(_, let deletions, let insertions, let modifications):
                insertions.forEach({ (index) in
                    let todoItemEntity = todoItemResults![index]
                    let itemIndex = todoItemEntity.todoId
                    print(itemIndex)
                    let newValue = todoItemEntity.todoValue
                    let newItem = TodoItemViewModel(id: "\(itemIndex)", textValue: newValue, parentViewmodel: self!)
                    self?.items.value.append(newItem)
                    print(self?.database?.fetch())
                })
                
                modifications.forEach({ (index) in
                    let todoItemEntity = todoItemResults![index]
                    
                    guard let index = self?.items.value.index(where: {Int($0.id!) == todoItemEntity.todoId}) else {
                        print("Item with this index doesn't exist")
                        return
                    }
//
//                    if todoItemEntity.deletedAt != nil {
//                        self?.items.value.remove(at: index)
//                        self?.database?.delete(primaryKey: todoItemEntity.todoId)
//                        print(self?.database?.fetch())
//                        return
//                    } else {
                        let todoItemViewModel = self?.items.value[index]
                        todoItemViewModel?.isDone = todoItemEntity.isDone
                        if var doneMenuItem = todoItemViewModel?.menuItems?.filter({ (todoMenu) -> Bool in
                            todoMenu is DoneMenuItemViewModel
                        }).first {
                            doneMenuItem.title = todoItemEntity.isDone ? "Undone" : "Done"
                            print(self?.database?.fetch())
                        }
                    //}
                })
                
                deletions.forEach({ (index) in
                    let realm = try! Realm()
                    realm.objects(TodoItem.self).sorted(byKeyPath: "todoId", ascending: true)
                    print("abc")
                    self?.items.value.remove(at: index)
                    print(self?.database?.fetch())
                })
                
                break
            case .error( _):
                break
            }
            
            self?.items.value.sort {
                if $0.isDone! && $1.isDone! {
                    return $0.id! < $1.id!
                }
                
                if !($0.isDone!) && !($1.isDone!) {
                    return $0.id! < $1.id!
                }
                return !($0.isDone!) && $1.isDone!
            }
        })
    }
}

extension TodoViewModel: TodoViewDelegate {
    func onDoneTodoItem(todoId: Int) {
        database?.isDone(primaryKey: todoId)
    }
    
    func onDeleteTodoItem(todoId: Int) {
        self.database?.delete(primaryKey: todoId)
    }
    
    func onAddTodoItem() {
        guard let newValue = newTodoItem else {
             print("New value is empty")
            return
        }
        self.database?.createOrUpdate(todoItemValue: newValue)
    }
}

extension TodoItemViewModel: TodoItemViewDelegate {
    func onRemoveSelected() {
        parent?.onDeleteTodoItem(todoId: Int(id!)!)
    }
    
    func onDoneSelected() {
        parent?.onDoneTodoItem(todoId: Int(id!)!)
    }
    
    func onItemSelected() {
        print("Did select row at received for item with id = \(id!)")
    }
}
