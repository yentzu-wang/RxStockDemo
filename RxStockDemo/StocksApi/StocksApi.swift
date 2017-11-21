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

protocol StocksApiProtocol {
    func intraDayNewestQuery(symbol: String, interval: QueryInterval) -> Observable<StockPrice>
}

final class StocksApi: StocksApiProtocol {
    static let shared = StocksApi()
    private let url = "https://www.alphavantage.co/query"
    private let bag = DisposeBag()
    
    private init() {}
    
    func parseIntraDayHistoryDataToRealm(symbol: String, interval: QueryInterval) -> Observable<[Stock]> {
        return intraDayHistoryQuery(symbol: symbol, interval: interval)
            .do(onNext: { stocks in
                _ = stocks.map({ stock in
                    let realm = try! Realm()
                    try! realm.write {
                        let stockPrice = StockPrice()
                        stockPrice.symbol = symbol
                        stockPrice.date = stock.dateTime.toDate!
                        stockPrice.open = stock.price.open
                        stockPrice.high = stock.price.high
                        stockPrice.low = stock.price.low
                        stockPrice.close = stock.price.close
                        stockPrice.volume = stock.price.volume
                        
                        realm.add(stockPrice, update: true)
                    }
                })
            })
    }
    
    func intraDayHistoryQuery(symbol: String, interval: QueryInterval) -> Observable<[Stock]> {
        let params = ["function": "TIME_SERIES_INTRADAY",
                      "symbol": symbol,
                      "outputsize": "compact",
                      "interval": interval.rawValue,
                      "apikey": getRandomKey()]
        
        return requestJSON(try! urlRequest(.get, url, parameters: params))
            .flatMap { arg -> Observable<[Stock]> in
                guard arg.0.statusCode == 200 else {
                    throw RxAlamofireUnknownError
                }
                
                if let json = arg.1 as? [String: Any],
                    let price = json["Time Series (\(interval.rawValue))"] as? [String: Any] {
                    let stocks = price.map { arg -> Stock in
                        let value = arg.value as! [String: String]
                        let open = value["1. open"]!.toDouble
                        let high = value["2. high"]!.toDouble
                        let low = value["3. low"]!.toDouble
                        let close = value["4. close"]!.toDouble
                        let volume = value["5. volume"]!.toInt
                        
                        let price = Price(open: open, high: high, low: low, close: close, volume: volume)
                        let stock = Stock(symbol: symbol, dateTime: arg.key, price: price)
                        
                        return stock
                    }
                    
                    return Observable.of(stocks)
                } else {
                    throw RxAlamofireUnknownError
                }
        }
    }
    
    func intraDayNewestQuery(symbol: String, interval: QueryInterval) -> Observable<StockPrice> {
        let params = ["function": "TIME_SERIES_INTRADAY",
                      "symbol": symbol,
                      "outputsize": "compact",
                      "interval": interval.rawValue,
                      "apikey": getRandomKey()]
        
        return requestJSON(try! urlRequest(.get, url, parameters: params))
            .flatMap { (arg) -> Observable<StockPrice> in
                guard arg.0.statusCode == 200 else {
                    throw RxAlamofireUnknownError
                }
                
                if let json = arg.1 as? [String: Any], let price = json["Time Series (\(interval.rawValue))"] as? [String: Any] {
                    let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "InMemoryRealm"))
                    
                    for keyValuePair in price {
                        if let values = keyValuePair.value as? [String: String],
                            let open = values["1. open"],
                            let high = values["2. high"],
                            let low = values["3. low"],
                            let close = values["4. close"],
                            let volume = values["5. volume"] {
                            
                            let stockPrice = StockPrice()
                            stockPrice.symbol = symbol
                            stockPrice.date = keyValuePair.key.toDate!
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
                    let price = realm.objects(StockPrice.self).sorted(byKeyPath: "date", ascending: false).first!
                    
                    return Observable.just(price)
                } else {
                    throw RxAlamofireUnknownError
                }
        }
    }

    private func getRandomKey() -> String {
        let randomIndex = GKRandomSource.sharedRandom().nextInt(upperBound: apiKeys.count)
        
        return apiKeys[randomIndex]
    }
}
