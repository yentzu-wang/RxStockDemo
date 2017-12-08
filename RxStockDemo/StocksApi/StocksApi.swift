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
import RealmSwift

enum QueryInterval: String {
    case oneMin = "1min"
    case fiveMins = "5min"
    case fifteenMins = "15min"
    case thirtyMins = "30min"
    case sixtyMins = "60min"
    case daily = "Daily"
}

struct TimeSeriesIntraday: Codable {
    let metaData: String
    let timeSeries: String
}

struct Stock {
    let symbol: String
    let dateTime: String
    let price: Price
}

struct Price {
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Int
    
    private enum CodingKeys: String, CodingKey {
        case open = "1. open"
        case high = "2. high"
        case low = "3. low"
        case close = "4. close"
        case volume = "5. volume"
    }
}

struct Performance {
    let sector: String
    let changePercentage: Double
}

enum PerformanceInterval: String {
    case realTime = "Rank A: Real-Time Performance"
    case oneDay = "Rank B: 1 Day Performance"
    case fiveDay = "Rank C: 5 Day Performance"
    case oneMonth = "Rank D: 1 Month Performance"
    case fiveMonth = "Rank E: 3 Month Performance"
    case yearToDate = "Rank F: Year-to-Date (YTD) Performance"
    case oneYear = "Rank G: 1 Year Performance"
    case threeYear = "Rank H: 3 Year Performance"
    case fiveYear = "Rank I: 5 Year Performance"
    case tenYear = "Rank J: 10 Year Performance"
}

protocol StocksApiProtocol {
    func stockPriceQuery(symbol: String, interval: QueryInterval) -> Observable<StockPrice?>
    func sectorQuery() -> Observable<Results<SectorPerformance>>
}

final class StocksApi: StocksApiProtocol {
    static let shared = StocksApi()
    private let url = "https://www.alphavantage.co/query"
    private let bag = DisposeBag()
    
    private init() {}
    
    func stockPriceQuery(symbol: String, interval: QueryInterval) -> Observable<StockPrice?> {
        let functionName = interval == .daily ? "TIME_SERIES_DAILY" : "TIME_SERIES_INTRADAY"
        let params = interval == .daily ? ["function": functionName,
                                           "symbol": symbol,
                                           "apikey": getRandomKey()] : ["function": functionName,
                                                                        "symbol": symbol,
                                                                        "outputsize": "compact",
                                                                        "interval": interval.rawValue,
                                                                        "apikey": getRandomKey()]
        
        return requestJSON(try! urlRequest(.get, url, parameters: params))
            .flatMap { (arg) -> Observable<StockPrice?> in
                guard arg.0.statusCode == 200 else {
                    throw RxAlamofireUnknownError
                }
                
                if let json = arg.1 as? [String: Any], let price = json["Time Series (\(interval.rawValue))"] as? [String: Any] {
                    let realm =  interval == .daily ? try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "InMemoryRealmDaily")) : try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "InMemoryRealm"))
                    
                    let previousPrices = realm.objects(StockPrice.self).filter("symbol = %@", symbol)
                    try! realm.write {
                        realm.delete(previousPrices)
                    }
                    
                    for keyValuePair in price {
                        if let values = keyValuePair.value as? [String: String],
                            let open = values["1. open"],
                            let high = values["2. high"],
                            let low = values["3. low"],
                            let close = values["4. close"],
                            let volume = values["5. volume"] {
                            
                            let stockPrice = StockPrice()
                            stockPrice.symbol = symbol
                            stockPrice.date = interval == .daily ? keyValuePair.key.toShortDate! : keyValuePair.key.toDate!    
                            stockPrice.open = open.toDouble
                            stockPrice.high = high.toDouble
                            stockPrice.low = low.toDouble
                            stockPrice.close = close.toDouble
                            stockPrice.volume = volume.toInt
                            
                            try! realm.write {
                                realm.add(stockPrice, update: true)
                            }
                        }
                    }
                    
                    let price = interval == .daily ? realm.objects(StockPrice.self).sorted(byKeyPath: "date", ascending: false)[1] : realm.objects(StockPrice.self).sorted(byKeyPath: "date", ascending: false).first
                    
                    return Observable.just(price)
                } else {
                    throw RxAlamofireUnknownError
                }
        }
    }
    
    func sectorQuery() -> Observable<Results<SectorPerformance>> {
        let params = ["function": "SECTOR", "apikey": getRandomKey()]
        
        return requestJSON(try! urlRequest(.get, url, parameters: params))
            .flatMap({ (arg) -> Observable<Results<SectorPerformance>> in
                guard arg.0.statusCode == 200 else {
                    throw RxAlamofireUnknownError
                }
                
                if let json = arg.1 as? [String: Any], let performance = json[PerformanceInterval.realTime.rawValue] as? [String: String] {
                    let realm = try! Realm()
                    
                    for keyValuePair in performance {
                        let sectorPerformance = SectorPerformance()
                        sectorPerformance.sector = keyValuePair.key
                        sectorPerformance.changePercentage = keyValuePair.value
                        
                        try! realm.write {
                            realm.add(sectorPerformance, update: true)
                        }
                    }
                    
                    let performance = realm.objects(SectorPerformance.self)
                        .sorted(byKeyPath: "sector", ascending: false)
                    
                    return Observable.just(performance)
                } else {
                    throw RxAlamofireUnknownError
                }
            })
    }
    
    private func getRandomKey() -> String {
        let randomIndex = GKRandomSource.sharedRandom().nextInt(upperBound: apiKeys.count)
        
        return apiKeys[randomIndex]
    }
}
