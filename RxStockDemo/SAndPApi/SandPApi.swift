//
//  SandPApi.swift
//  RxStockDemo
//
//  Created by Frank on 2017/11/08.
//  Copyright © 2017 Frank. All rights reserved.
//

import Foundation
import RxSwift
import RxAlamofire
import RealmSwift

struct Symbol: Codable {
    let name: String?
    let sector: String?
    let symbol: String?
    
    private enum CodingKeys: String, CodingKey {
        case name = "Name"
        case sector = "Sector"
        case symbol = "Symbol"
    }
}

protocol SandPApiProtocol {
    func getSymbols() -> Observable<[Symbol]>
}

final class SandPApi: SandPApiProtocol {
    static let shared = SandPApi()
    private let symbolUrl = "https://pkgstore.datahub.io/core/s-and-p-500-companies:constituents_json/data/constituents_json.json"
    private let bag = DisposeBag()
    private init() {}
    
    func getSymbols() -> Observable<[Symbol]> {
        return request(.get, symbolUrl)
            .flatMap { request in
                return request.validate(statusCode: 200 ..< 300)
                    .rx.data()
            }
            .map { data -> [Symbol] in
                do {
                    return try JSONDecoder().decode([Symbol].self, from: data)
                } catch {
                    return [Symbol]()
                }
        }
    }
    
    func parseDataToRealm() {
        _ = getSymbols()
            .subscribe(onNext: { (symbols) in
                _ = symbols.map({ symbol in
                    let realm = try! Realm()
                    let stockSymbol = realm.object(ofType: StockSymbol.self, forPrimaryKey: symbol.symbol!)
                    
                    if stockSymbol == nil {
                        let stockSymbol = StockSymbol()
                        stockSymbol.symbol = symbol.symbol!
                        stockSymbol.name = symbol.name!
                        stockSymbol.sector = symbol.sector!
                        
                        try! realm.write {
                            realm.add(stockSymbol)
                        }
                    } else if let stockSymbol = stockSymbol {
                        try! realm.write {
                            stockSymbol.name = symbol.name!
                            stockSymbol.sector = symbol.sector!
                        }
                    }
                })
            })
            .disposed(by: bag)
    }
}



