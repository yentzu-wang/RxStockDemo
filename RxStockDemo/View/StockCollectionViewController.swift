//
//  ViewController.swift
//  RxStockDemo
//
//  Created by Frank on 2017/11/07.
//  Copyright © 2017 Frank. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift
import RxRealmDataSources

class StockCollectionViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let bag = DisposeBag()
    private var viewModel: StockCollectionViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = StockCollectionViewModel()
//        foo.fetchStockPortfolio()
        
//        viewModel.subscriptNewestPrice(symbol: "CAT", interval: QueryInterval.oneMin)
//        .asObservable()
//            .subscribe(onNext: { (price) in
//                print(price)
//            })
//        .disposed(by: bag)
        
        
        let foo = viewModel.subscription
        
        _ = foo.map {
            $0.asObservable()
                .subscribe(onNext: { (stockPrice) in
                    print(stockPrice)
                })
                .disposed(by: bag)
        }
        
        
        
        bindUI()
        
    }
    
    private func bindUI() {
        collectionView.rx.setDelegate(self)
            .disposed(by: bag)
        
        
        
        //        let items = StocksApi.shared.intraDayHistoryQuery(symbol: "CAT", interval: .fiveMins)
        //
        //        items.bind(to: collectionView.rx.items) { (collectionView, row, element) in
        //            let indexPath = IndexPath(row: row, section: 0)
        //            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Stock", for: indexPath)
        //            return cell
        //        }
        //        .disposed(by: bag)
        
        let addButton = navigationItem.rightBarButtonItem
        
        addButton?.rx.tap
            .subscribe(onNext: {
                self.performSegue(withIdentifier: "ToStockPicker", sender: nil)
            })
            .disposed(by: bag)
    }
    
    private func bindCollectionView() {
        let dataSource = RxCollectionViewRealmDataSource<StockPortfolio>(cellIdentifier: "Stock", cellType: StockCollectionViewCell.self) { (cell, indexPath, portfolio) in
            
        }
    }
}

extension StockCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let cellWidth = width / 2
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

