//
//  StockSymbol.swift
//  RxStockDemo
//
//  Created by Frank on 2017/11/13.
//  Copyright © 2017 Frank. All rights reserved.
//

import Foundation
import RealmSwift

class StockSymbol: Object {
    @objc dynamic var symbol: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var sector: String = ""
    
    override static func primaryKey() -> String? {
        return "symbol"
    }
}
