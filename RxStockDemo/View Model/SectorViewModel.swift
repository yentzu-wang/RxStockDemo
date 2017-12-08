//
//  SectorViewModel.swift
//  RxStockDemo
//
//  Created by Frank on 2017/12/08.
//  Copyright © 2017 Frank. All rights reserved.
//

import Foundation
import RxSwift
import Realm
import RealmSwift

protocol SectorViewModelProtocol {
    var sectors: Results<SectorPerformance> { get }
}

class SectorViewModel: SectorViewModelProtocol {
    let sectors: Results<SectorPerformance>
    private let bag = DisposeBag()
    
    init() {
        let realm = try! Realm()
        sectors = realm.objects(SectorPerformance.self).sorted(byKeyPath: "sector", ascending: true)
        
        fetchData()
    }
    
    private func fetchData() {
        StocksApi.shared.sectorQuery()
            .subscribe(onNext: { _ in
                print("Fetching data...")
            })
            .disposed(by: bag)
    }
}
