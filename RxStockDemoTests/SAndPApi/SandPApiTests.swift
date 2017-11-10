//
//  SandPApiTests.swift
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

class SandPApiTests: XCTestCase {
    var sut: MockSandPApi!
    var testObj: [Symbol]!
    let foo1 = Symbol(name: "foo1", sector: "foo1", symbol: "foo1")
    
    let url = "https://pkgstore.datahub.io/core/s-and-p-500-companies:constituents_json/data/constituents_json.json"
    let fakeUrl = "http://fakeurl.com"
    
    override func setUp() {
        super.setUp()
        
        sut = MockSandPApi()
        testObj = [Symbol]()
        testObj.append(foo1)
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
    
    func testGetSymbols() {
        let symbol = sut.getSymbols()
        .toBlocking()
        .firstOrNil()
        
        expect(symbol).notTo(beNil())
    }
}

extension SandPApiTests {
    class MockSandPApi: SandPApiProtocol {
        func getSymbols() -> Observable<[Symbol]> {
            let symbol = Symbol(name: "foo", sector: "foo", symbol: "foo")
            return Observable.just([symbol])
        }
    }
}

extension BlockingObservable {
    func firstOrNil() -> E? {
        do {
            return try first()
        } catch {
            return nil
        }
    }
}
