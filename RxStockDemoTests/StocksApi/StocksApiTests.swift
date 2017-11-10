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
    var sut: MockStocksApiTests!
    var testObj: Stock!
    let price = Price(open: 0, high: 0, low: 0, close: 0, volume: 0)
    
    let url = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=MSFT&interval=1min&outputsize=full"
    let fakeUrl = "http://fakeurl.com"
    
    override func setUp() {
        super.setUp()
        
        sut = MockStocksApiTests()
        testObj = Stock(symbol: "foo", dateTime: "2017-1-1 13:20:00", price: price)
        stub(condition: isHost(url)) { _ in
            return OHHTTPStubsResponse(jsonObject: self.testObj, statusCode: 200, headers: nil)
        }
        stub(condition: isHost(fakeUrl)) { _ in
            return OHHTTPStubsResponse(error: RxAlamofireUnknownError)
        }
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testData() {
        let observable = data(.get, url)
            .toBlocking()
            .firstOrNil()
        
        expect(observable).notTo(beNil())
    }
    
    func testError() {
        var erroredCorrectly = false
        let observable = data(.get, fakeUrl)
        
        do {
            let _ = try observable.toBlocking().first()
            assertionFailure()
        } catch {
            erroredCorrectly = true
        }
        
        expect(erroredCorrectly) == true
    }
    
    func testRequestJSON() {
        let request = try? urlRequest(.get, url)
        expect(request).notTo(beNil())
        
        let observable = data(.get, request!.url!)
            .toBlocking()
            .firstOrNil()
        
        expect(observable).notTo(beNil())
    }
    
    func testIntraDayQuery() {
        let stock = sut.intraDayQuery(symbol: "foo", interval: .fiveMins)
            .toBlocking()
            .firstOrNil()
        
        expect(stock?.symbol) == "foo"
    }
}

extension StocksApiTests {
    class MockStocksApiTests: StocksApiProtocol {
        func intraDayQuery(symbol: String, interval: QueryInterval) -> Observable<Stock> {
            let price = Price(open: 0, high: 0, low: 0, close: 0, volume: 0)
            let testObj = Stock(symbol: symbol, dateTime: "2015-2-3 14:20:00", price: price)
            return Observable.just(testObj)
        }
        
        
    }
}
