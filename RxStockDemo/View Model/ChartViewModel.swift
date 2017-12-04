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
import RxSwift
import RxRealm

protocol ChartViewModelProtocol {
    var prices: Observable<(AnyRealmCollection<StockPrice>, RealmChangeset?)> { get }
}

class ChartViewModel: ChartViewModelProtocol {
    private let symbol: String
    private let bag = DisposeBag()
    let prices: Observable<(AnyRealmCollection<StockPrice>, RealmChangeset?)>
    
    init(symbol: String) {
        self.symbol = symbol
        let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "InMemoryRealmDaily"))
        let result = realm.objects(StockPrice.self)
                .filter("symbol = '\(symbol)'")
            .sorted(byKeyPath: "date", ascending: true)
        prices = Observable.changeset(from: result)
        
        fetchData()
    }
    
    private func fetchData() {
        StocksApi.shared.stockPriceQuery(symbol: symbol, interval: .daily)
            .subscribe(onNext: { _ in
               print("Fetching data...")
            })
        .disposed(by: bag)
    }
}
