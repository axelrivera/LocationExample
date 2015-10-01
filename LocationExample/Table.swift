//
//  TableUtils.swift
//  LocationExample
//
//  Created by Axel Rivera on 9/25/15.
//  Copyright © 2015 Axel Rivera. All rights reserved.
//

import Foundation
import UIKit

typealias TableInfo = [String: Any]
typealias TableSectionArray = [TableSection]
typealias TableRowArray = [TableRow]

enum TableRowType {
    case Text
    case Detail
    case Subtitle
    case Custom
}

struct TableSection {
    var identifier: String?
    var title: String?
    var footer: String?
    var rows = TableRowArray()
    
    init(title: String?, rows: TableRowArray) {
        self.title = title
        self.rows = rows
    }
}

struct TableRow {
    var rowType: TableRowType = .Custom
    var identifier: String?
    var groupIdentifier: String?
    var text: String?
    var detail: String?
    var userInfo = TableInfo()
    var object: AnyObject?
    var height: CGFloat?
    
    init(type: TableRowType) {
        self.rowType = type
    }
    
    init(type: TableRowType, text: String?, detail: String?) {
        self.rowType = type
        self.text = text
        self.detail = detail
    }
    
    init(text: String?) {
        self.rowType = .Text
        self.text = text
    }
    
    init(text: String?, detail: String?) {
        self.rowType = .Detail
        self.text = text
        self.detail = detail
    }
    
    init(object: AnyObject?) {
        self.rowType = .Custom
        self.object = object
    }
    
}
