//
//  StockCollectionViewModel.swift
//  RxStockDemo
//
//  Created by Frank on 2017/11/20.
//  Copyright © 2017 Frank. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

class StockCollectionViewModel {
    private let bag = DisposeBag()
    let subscription: Results<StockSubscription> = {
        let realm = try! Realm()
        return realm.objects(StockSubscription.self)
            .sorted(byKeyPath: "symbol", ascending: true)
    }()
    
    init() {
        fetchStockPortfolio()
    }
    
    private func subscriptNewestPrice(symbol: String, interval: QueryInterval) {
        let timer = Observable<Int>.interval(5, scheduler: MainScheduler.instance)
        
        timer
            .startWith(-1)
            .share()
            .subscribe { [unowned self] _ in
                StocksApi.shared.stockPriceQuery(symbol: symbol, interval: interval)
                    .asDriver(onErrorJustReturn: nil)
                    .asObservable()
                    .subscribe(onNext: { stockPrice in
                        if let stockPrice = stockPrice {
                            let realm = try! Realm()
                            
                            let subscription = StockSubscription()
                            subscription.symbol = stockPrice.symbol
                            subscription.date = stockPrice.date
                            subscription.open = stockPrice.open
                            subscription.high = stockPrice.high
                            subscription.low = stockPrice.low
                            subscription.close = stockPrice.close
                            subscription.volume = stockPrice.volume
                            
                            try! realm.write {
                                realm.add(subscription, update: true)
                            }
                        }
                    })
                    .disposed(by: self.bag)
            }
            .disposed(by: bag)
    }
    
    private func fetchStockPortfolio() {
        let realm = try! Realm()
        let stockPortfolio = realm.objects(StockPortfolio.self).sorted(byKeyPath: "symbol", ascending: true)
        
        for stock in stockPortfolio {
            subscriptNewestPrice(symbol: stock.symbol, interval: .oneMin)
        }
    }
}
