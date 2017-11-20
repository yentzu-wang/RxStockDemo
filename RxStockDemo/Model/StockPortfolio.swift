//
//  StockPortfolio.swift
//  RxStockDemo
//
//  Created by Frank on 2017/11/15.
//  Copyright © 2017 Frank. All rights reserved.
//

import Foundation
import RealmSwift

class StockPortfolio: Object {
    @objc dynamic var symbol: String = ""
    let lastTradeDayClose = RealmOptional<Double>()
    
    override static func primaryKey() -> String? {
        return "symbol"
    }
}
