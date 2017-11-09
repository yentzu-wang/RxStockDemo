//
//  File.swift
//  RxStockDemo
//
//  Created by Frank on 2017/11/09.
//  Copyright © 2017 Frank. All rights reserved.
//

// Read me first:
// To own your api keys, please go to: https://www.alphavantage.co/ to claim as many keys as you want (because each key has its frequency limitations).
// You also need to create an array holding api keys - apiKeys: [String] during api services calling.

import Foundation
import RxSwift
import RxAlamofire
import GameplayKit

enum QueryInterval: String {
    case oneMin = "1min"
    case fiveMins = "5min"
    case fifteenMins = "15min"
    case thirtyMins = "30min"
    case sixtyMins = "60min"
}

struct Stock: Codable {
    let symbol: String?
    let dateTime: String?
    let open: String
    let high: String
    let low: String
    let close: String
    let volume: String
}

final class StocksApi {
    static let shared = StocksApi()
    private let url = "https://www.alphavantage.co/query"
    private let bag = DisposeBag()
    
    private init() {}
    
//    func intraDayQuery(symbol: String, interval: QueryInterval) {
//        let params = ["function": "TIME_SERIES_INTRADAY",
//                      "symbol": symbol,
//                      "interval": interval.rawValue]
//        
//        let r = requestData(try! urlRequest(.get, url, parameters: params))
//            .flatMap { arg -> Observable<Data> in
//                print(arg.1)
//                return Observable.of(arg.1)
//            }
//        .map
//        
//        
//    }
    
    private func getRandomKey() -> String {
        let randomIndex = GKRandomSource.sharedRandom().nextInt(upperBound: apiKeys.count)
        
        return apiKeys[randomIndex]
    }
}
