//
//  String+Extension.swift
//  RxStockDemo
//
//  Created by Frank on 2017/11/10.
//  Copyright © 2017 Frank. All rights reserved.
//

import Foundation

extension String {
    var toDouble: Double {
        return Double(self) ?? 0.0
    }
    
    var toInt: Int {
        return Int(self) ?? 0
    }
    
    var toDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:00"
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        let date = dateFormatter.date(from: self)
        
        return date
    }
    
    var toShortDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        let date = dateFormatter.date(from: self)
        
        return date
    }
}
