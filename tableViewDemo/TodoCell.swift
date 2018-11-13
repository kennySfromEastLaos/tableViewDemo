//
//  TodoCell.swift
//  tableViewDemo
//
//  Created by kennyS on 11/12/18.
//  Copyright © 2018 LTT. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TodoCell: UITableViewCell {

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /// configure cell
    func configureCell(viewmodel: TodoItemPresentable) {
        idLabel.text = String(viewmodel.id!)
        let attributedString = NSMutableAttributedString(string: viewmodel.textValue!)
        
        if viewmodel.isDone! {
            let range = NSMakeRange(0, attributedString.length)
            attributedString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.red, range: range)
            attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: range)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: range)
        }
        contentLabel.attributedText = attributedString
    }

}
