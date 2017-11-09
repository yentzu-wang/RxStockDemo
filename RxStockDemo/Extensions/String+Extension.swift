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
}
