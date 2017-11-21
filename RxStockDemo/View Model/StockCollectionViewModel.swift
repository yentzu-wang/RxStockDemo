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
    
    func subscriptNewestPrice(symbol: String, interval: QueryInterval) -> Variable<StockPrice?> {
        var price: StockPrice? = nil
        let variable = Variable(price)
        let timer = Observable<Int>.interval(5, scheduler: MainScheduler.instance)
        
        timer
            .startWith(-1)
            .subscribe { [unowned self] _ in
                StocksApi.shared.intraDayNewestQuery(symbol: symbol, interval: interval)
                    .asDriver(onErrorJustReturn: price)
                    .asObservable()
                    .subscribe(onNext: { stockPrice in
                        price = stockPrice
                        variable.value = stockPrice
                    })
                    .disposed(by: self.bag)
            }
            .disposed(by: bag)
        
        return variable
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
