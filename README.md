# RxStockDemo

## About
It is a demonstration of RxSwift and Realm with MVVM design pattern. Stock tickers are **real-time** updated during NYSE market opens.

Because it is only a demonstration of a real-world scenario using RxSwift with MVVM, I focus on the minimal function sets of a stock ticker app 
rather than fancy user interface design and redundant functionalities.
* Candlestick charts included.
## How to use
To own your api keys, please go to: https://www.alphavantage.co/ to claim as many keys as you want (because each key has its frequency limitations). 
You also need to create an array holding api keys - **apiKeys: [String]** during api services calling.

Api references:
* https://pkgstore.datahub.io/core/s-and-p-500-companies:constituents_json/data/constituents_json.json
* https://www.alphavantage.co/

## Thank
Thank you [RxSwift](https://github.com/ReactiveX/RxSwift) and [Realm](https://github.com/realm/realm-cocoa) teams!

You guys make iOS developers' lifes much easier. :)
