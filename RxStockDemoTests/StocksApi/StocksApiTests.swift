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
    
    func testIntraDayRealTimeQuery() {
        let stock = sut.intraDayRealTimeQuery(symbol: "foo", interval: .fiveMins)
            .toBlocking()
            .firstOrNil()
        
        expect(stock?.symbol) == "foo"
    }
}

extension StocksApiTests {
    class MockStocksApi: StocksApiProtocol {
        func intraDayRealTimeQuery(symbol: String, interval: QueryInterval) -> Observable<Stock> {
            let price = Price(open: 0, high: 0, low: 0, close: 0, volume: 0)
            let testObj = Stock(symbol: symbol, dateTime: "2015-2-3 14:20:00", price: price)
            return Observable.just(testObj)
        }
    }
}
