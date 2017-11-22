//
//  StockSubscription.swift
//  RxStockDemo
//
//  Created by Frank on 2017/11/22.
//  Copyright © 2017 Frank. All rights reserved.
//

import Foundation
import RealmSwift

class StockSubscription: Object {
    @objc dynamic var symbol: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var open: Double = 0.0
    @objc dynamic var high: Double = 0.0
    @objc dynamic var low: Double = 0.0
    @objc dynamic var close: Double = 0.0
    @objc dynamic var volume: Int = 0
    
    override static func primaryKey() -> String? {
        return "symbol"
    }
}

