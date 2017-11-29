//
//  StockCollectionViewModelTests.swift
//  RxStockDemoTests
//
//  Created by Frank on 2017/11/20.
//  Copyright © 2017 Frank. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import Nimble
import RxNimble
import RealmSwift
@testable import RxStockDemo

class StockCollectionViewModelTests: XCTestCase {
    var sut: StockCollectionViewModelProtocol!
    
    override func setUp() {
        super.setUp()
        
        sut = MockStockCollectionViewModel()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUpdateLastTradeDayClose() {
        let realm = try! Realm()
        let foo = realm.objects(StockPortfolio.self)
        
        sut.updateLastTradeDayClose(stockCollection: foo)
        
        let testResult = realm.objects(StockPortfolio.self)
            .filter("symbol = 'foo'")
        
        expect(testResult[0].lastTradeDayClose.value) == 100
    }
}

extension StockCollectionViewModelTests {
    class MockStockCollectionViewModel: StockCollectionViewModelProtocol {
        let subscription: Results<StockSubscription>
        private let bag = DisposeBag()
        
        init() {
            let realm = try! Realm()
            subscription = realm.objects(StockSubscription.self)
                .sorted(byKeyPath: "symbol", ascending: true)
        }
        
        func updateLastTradeDayClose(stockCollection: Results<StockPortfolio>) {
            let realm = try! Realm()
            
            try! realm.write {
                let stockPortfolio = StockPortfolio()
                stockPortfolio.symbol = "foo"
                stockPortfolio.lastTradeDayClose.value = 100
                
                realm.add(stockPortfolio, update: true)
            }
        }
    }
}
