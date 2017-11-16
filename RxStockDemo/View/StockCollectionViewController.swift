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
import RxDataSources

class StockCollectionViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
        
        StocksApi.shared.parseIntraDayHistoryDataToRealm(symbol: "CAT", interval: .oneMin)
            .subscribe(onNext: { (stocks) in
                print(stocks)
            })
            .disposed(by: bag)
    }
    
    private func bindUI() {
        collectionView.rx.setDelegate(self)
            .disposed(by: bag)
        
        let items = StocksApi.shared.intraDayHistoryQuery(symbol: "CAT", interval: .fiveMins)
        
        items.bind(to: collectionView.rx.items) { (collectionView, row, element) in
            let indexPath = IndexPath(row: row, section: 0)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Stock", for: indexPath)
            return cell
        }
        .disposed(by: bag)
        
        let addButton = navigationItem.rightBarButtonItem
        
        addButton?.rx.tap
            .subscribe(onNext: {
                self.performSegue(withIdentifier: "ToStockPicker", sender: nil)
            })
        .disposed(by: bag)
    }
}

extension StockCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let cellWidth = width / 2
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
