//
//  SectorViewModelTests.swift
//  RxStockDemoTests
//
//  Created by Frank on 2017/12/08.
//  Copyright © 2017 Frank. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import Nimble
import RxNimble
import RealmSwift
@testable import RxStockDemo

class SectorViewModelTests: XCTestCase {
    var sut: SectorViewModelProtocol!
    override func setUp() {
        super.setUp()
        
        sut = MockSectorViewModel()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSectorsNotNil() {
        expect(self.sut.sectors).notTo(beNil())
    }
}

extension SectorViewModelTests {
    class MockSectorViewModel: SectorViewModelProtocol {
        var sectors: Results<SectorPerformance>
        
        init() {
            let realm = try! Realm()
            sectors = realm.objects(SectorPerformance.self)
        }
    }
}
