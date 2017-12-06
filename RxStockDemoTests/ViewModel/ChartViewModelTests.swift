//
//  ChartViewModelTests.swift
//  RxStockDemoTests
//
//  Created by Frank on 2017/12/03.
//  Copyright © 2017 Frank. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import Nimble
import RxNimble
import RealmSwift
import RxSwift
import RxRealm
@testable import RxStockDemo

class ChartViewModelTests: XCTestCase {
    var sut: ChartViewModelProtocol!
    
    override func setUp() {
        super.setUp()
        
        sut = MockChartViewModelProtocol()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPricesNotNil() {
        expect(self.sut.prices).notTo(beNil())
    }
}

extension ChartViewModelTests {
    class MockChartViewModelProtocol: ChartViewModelProtocol {
        var prices: Observable<(AnyRealmCollection<StockPrice>, RealmChangeset?)>
        
        init() {
            let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "InMemoryRealmDailyTesting"))
            let result = realm.objects(StockPrice.self)
                .filter("symbol = 'foo'")
                .sorted(byKeyPath: "date", ascending: true)
            prices = Observable.changeset(from: result)
        }
    }
}
