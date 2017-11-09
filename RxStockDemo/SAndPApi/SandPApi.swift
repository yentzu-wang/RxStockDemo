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

class SandPApi {
    static let shared = SandPApi()
    private let symbolUrl = "https://pkgstore.datahub.io/core/s-and-p-500-companies:constituents_json/data/constituents_json.json"
    
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
}



