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
    func subscriptNewestPrice(symbol: String, interval: QueryInterval) -> PublishSubject<StockPrice> {
        let bag = DisposeBag()
        let subject = PublishSubject<StockPrice>()
        
        let timer = Observable<Int>.interval(15, scheduler: MainScheduler.instance)
        timer
            .startWith(-1)
            .subscribe { _ in
                StocksApi.shared.intraDayNewestQuery(symbol: symbol, interval: interval)
                    .subscribe(onNext: { (stockPrice) in
                        subject.onNext(stockPrice)
                    })
                    .disposed(by: bag)
            }
            .disposed(by: bag)
        
        return subject
    }
    
    func fetchStockPortfolio() {
        let realm = try! Realm()
        let stockPortfolio = realm.objects(StockPortfolio.self).sorted(byKeyPath: "symbol", ascending: true)
        
        var stocks: [String] = []
        
        for stock in stockPortfolio {
            stocks.append(stock.symbol)
        }
        
    }
}
