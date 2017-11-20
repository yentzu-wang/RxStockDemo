//
//  SymbolPickerViewModelTests.swift
//  RxStockDemoTests
//
//  Created by Frank on 2017/11/19.
//  Copyright © 2017 Frank. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import Nimble
import RxNimble
import RealmSwift
@testable import RxStockDemo

class SymbolPickerViewModelTests: XCTestCase {
    var sut: SymbolPickerProtocol!
    
    override func setUp() {
        super.setUp()
        
        sut = MockSymbolPickerViewModel()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSymbolsNotNil() {
        expect(self.sut.symbols).notTo(beNil())
    }
}

extension SymbolPickerViewModelTests {
    class MockSymbolPickerViewModel: SymbolPickerProtocol {
        var symbols: Results<StockSymbol>
        
        init() {
            let realm = try! Realm()
            symbols = realm.objects(StockSymbol.self).sorted(byKeyPath: "symbol", ascending: true)
        }
    }
}
