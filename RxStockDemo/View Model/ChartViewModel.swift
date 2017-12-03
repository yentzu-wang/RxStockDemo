//
//  ChartViewModel.swift
//  RxStockDemo
//
//  Created by Frank on 2017/12/03.
//  Copyright © 2017 Frank. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

protocol ChartViewModelProtocol {
    var prices: Results<StockPrice> { get set }
}

class ChartViewModel: ChartViewModelProtocol {
    var prices: Results<StockPrice>
    
    init(symbol: String) {
        let realm = try! Realm()
        prices = realm.objects(StockPrice.self).sorted(byKeyPath: "date", ascending: true)
    }
}
