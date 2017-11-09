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

final class StocksApi {
    static let shared = StocksApi()
    private let url = "https://www.alphavantage.co/query"
    private let bag = DisposeBag()
    
    private init() {}
    
    func intraDayQuery(symbol: String, interval: QueryInterval) -> Observable<Stock> {
        let params = ["function": "TIME_SERIES_INTRADAY",
                      "symbol": symbol,
                      "outputsize": "compact",
                      "interval": interval.rawValue,
                      "apikey": getRandomKey()]
        
        return requestJSON(try! urlRequest(.get, url, parameters: params))
            .flatMap { (arg) -> Observable<Stock> in
                guard arg.0.statusCode == 200 else {
                    throw RxAlamofireUnknownError
                }
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:00"
                dateFormatter.timeZone = TimeZone(abbreviation: "EST")
                let estDateTime = dateFormatter.string(from: date)
                
                if let json = arg.1 as? [String: Any],
                    let price = json["Time Series (\(interval.rawValue))"] as? [String: Any],
                    let currentPrice = price[estDateTime] as? [String: String],
                    let open = currentPrice["1. open"],
                    let high = currentPrice["2. high"],
                    let low = currentPrice["3. low"],
                    let close = currentPrice["4. close"],
                    let volume = currentPrice["5. volume"] {
                    
                    let open = open.toDouble
                    let high = high.toDouble
                    let low = low.toDouble
                    let close = close.toDouble
                    let volume = volume.toInt
                    
                    let price = Price(open: open, high: high, low: low, close: close, volume: volume)
                    let stock = Stock(symbol: symbol, dateTime: estDateTime, price: price)
                    
                    return Observable.just(stock)
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
