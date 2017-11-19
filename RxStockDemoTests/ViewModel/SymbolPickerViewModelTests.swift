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
@testable import RxStockDemo

class SymbolPickerViewModelTests: XCTestCase {
    var sut: SymbolPickerViewModel!
    override func setUp() {
        super.setUp()
        
        sut = SymbolPickerViewModel()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
}
