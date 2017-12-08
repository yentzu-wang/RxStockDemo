//
//  SectorPerformance.swift
//  RxStockDemo
//
//  Created by Frank on 2017/12/07.
//  Copyright © 2017 Frank. All rights reserved.
//

import Foundation
import RealmSwift

class SectorPerformance: Object {
    @objc dynamic var sector: String = ""
    @objc dynamic var changePercentage: String = ""
    
    override static func primaryKey() -> String? {
        return "sector"
    }
}
