//
//  SymbolPickerViewModel.swift
//  RxStockDemo
//
//  Created by Frank on 2017/11/17.
//  Copyright © 2017 Frank. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

protocol SymbolPickerProtocol {
    var symbols: Results<StockSymbol> { get set }
}

class SymbolPickerViewModel: SymbolPickerProtocol {
    var symbols: Results<StockSymbol>
    
    init() {
        SandPApi.shared.parseDataToRealm()
        
        let realm = try! Realm()
        symbols = realm.objects(StockSymbol.self).sorted(byKeyPath: "symbol", ascending: true)
    }
}
