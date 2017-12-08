//
//  StocksApiTests.swift
//  RxStockDemoTests
//
//  Created by Frank on 2017/11/09.
//  Copyright © 2017 Frank. All rights reserved.
//

import XCTest
import RxSwift
import RxAlamofire
import RxBlocking
import Nimble
import RxNimble
import OHHTTPStubs
import RealmSwift
@testable import RxStockDemo

class StocksApiTests: XCTestCase {
    var sut: MockStocksApi!
    var testObj: Stock!
    let price = Price(open: 0, high: 0, low: 0, close: 0, volume: 0)
    
    let request = URLRequest(url: URL(string: "www.alphavantage.co")!)
    let errorRequest = URLRequest(url: URL(string: "fakeurl.com")!)
    
    override func setUp() {
        super.setUp()
        
        sut = MockStocksApi()
        testObj = Stock(symbol: "foo", dateTime: "2017-1-1 13:20:00", price: price)
        
        stub(condition: isHost("www.alphavantage.co")) { _ in
            return OHHTTPStubsResponse(jsonObject: self.testObj, statusCode: 200, headers: nil)
        }
        stub(condition: isHost("fakeurl.com")) { _ in
            return OHHTTPStubsResponse(error: RxAlamofireUnknownError)
        }
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testData() {
        let observable = URLSession.shared.rx.data(request: self.request)
        
        expect(observable).notTo(beNil())
    }
    
    func testError() {
        var erroredCorrectly = false
        let observable = URLSession.shared.rx.json(request: self.errorRequest)
        
        do {
            let _ = try observable.toBlocking().first()
            assertionFailure()
        } catch {
            erroredCorrectly = true
        }
        
        expect(erroredCorrectly) == true
    }
    
    func testStockPriceQuery() {
        let stock = sut.stockPriceQuery(symbol: "foo", interval: .fiveMins)
            .toBlocking()
            .firstOrNil()!
        
        expect(stock?.symbol) == "foo"
    }
    
    func testSectorQuery() {
        let performance = sut.sectorQuery()
        .toBlocking()
        .firstOrNil()
        
        expect(performance).notTo(beNil())
    }
}

extension StocksApiTests {
    class MockStocksApi: StocksApiProtocol {
        func sectorQuery() -> Observable<Results<SectorPerformance>> {
            let realm = try! Realm()
            
            let performance = realm.objects(SectorPerformance.self)
            
            return Observable.just(performance)
        }
        
        func stockPriceQuery(symbol: String, interval: QueryInterval) -> Observable<StockPrice?> {
            let stockPrice = StockPrice()
            stockPrice.symbol = "foo"
            return Observable.just(stockPrice)
        }
    }
}
