//
//  ViewController.swift
//  tableViewDemo
//
//  Created by Apple on 11/9/18.
//  Copyright © 2018 LTT. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var btAdd: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar { return searchController.searchBar }
    
    let disposeBag = DisposeBag()
    var viewmodel: TodoViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewmodel = TodoViewModel()
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchBar.sizeToFit()
        searchBar.backgroundColor = UIColor.clear
        searchBar.showsCancelButton = false
        searchBar.placeholder = "enter something"
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        tableView.delegate = self
        // bind data
        viewmodel?.searchItem.asObservable().bind(to: tableView.rx.items(cellIdentifier: "TodoCell", cellType: TodoCell.self)) { index, item, cell in
                cell.configureCell(viewmodel: item)
            }.disposed(by: disposeBag)
        
        btAdd.rx.tap
            .bind {
                guard let newTodoValue = self.textField.text, !newTodoValue.isEmpty else {
                    print("No value entered")
                    return
                }
                self.viewmodel?.newTodoItem = newTodoValue
                DispatchQueue.global(qos: .background).async {
                    self.viewmodel?.onAddTodoItem()
                    
                }
                self.textField.text = ""

        }.disposed(by: disposeBag)
        
        searchBar.rx.text
            .orEmpty
            .distinctUntilChanged()
            .debug()
            .bind(to: (viewmodel?.searchValue)!)
            .disposed(by: disposeBag)

    }
}

extension ViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let itemViewmodel = viewmodel?.items.value[indexPath.row]
        
        var menuActions: [UIContextualAction] = []
        
        _ = itemViewmodel?.menuItems?.map ({ menuItem in
            let menuAction = UIContextualAction(style: .normal, title: menuItem.title!) { (action, sourceview, success:  (Bool) -> Void) in
                if let delegate = menuItem as? TodoMenuItemViewDelegate {
                    DispatchQueue.global(qos: .background).async {
                        delegate.onMenuItemSelected()
                    }
                }
                success(true)
            }
            
            menuAction.backgroundColor = menuItem.backgroundColor?.hexColor
            menuActions.append(menuAction)
        })
        
        return UISwipeActionsConfiguration(actions: menuActions)
    }
}
