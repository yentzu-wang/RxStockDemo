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
        
        bindUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel = StockCollectionViewModel()
        
        bindCollectionView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToChart", let symbol = sender as? String, let destination = segue.destination as? ChartViewController {
            destination.symbol = symbol
        }
    }
    
    private func bindUI() {
        collectionView.rx.setDelegate(self)
            .disposed(by: bag)
        
        bindCollectionView()
        
        let addButton = navigationItem.rightBarButtonItem
        addButton?.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.performSegue(withIdentifier: "ToStockPicker", sender: nil)
            })
            .disposed(by: bag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                if let cell = self?.collectionView.cellForItem(at: indexPath) as? StockCollectionViewCell, let symbol = cell.symbolLabel.text {
                    self?.performSegue(withIdentifier: "ToChart", sender: symbol)
                }
            })
            .disposed(by: bag)
    }
    
    private func bindCollectionView() {
        let dataSource = RxCollectionViewRealmDataSource<StockSubscription>(cellIdentifier: "Stock", cellType: StockCollectionViewCell.self) { (cell, indexPath, stockPrice) in
            let realm = try! Realm()
            let stockPortfolio = realm.objects(StockPortfolio.self).filter("symbol = %@", stockPrice.symbol).first!
            if let lastTradeDayClose = stockPortfolio.lastTradeDayClose.value {
                if stockPrice.close > lastTradeDayClose {
                    cell.view.layer.borderColor = UIColor.red.cgColor
                    cell.priceLabel.textColor = .red
                    cell.priceChangeLabel.textColor = .red
                    cell.priceChangeLabel.text = String(floor(abs(stockPrice.close - lastTradeDayClose) * 100) / 100)
                    cell.changePercentageLabel.text = String(floor(abs((stockPrice.close - lastTradeDayClose) / lastTradeDayClose) * 100 * 100) / 100) + "%"
                    cell.changePercentageLabel.textColor = .red
                    cell.updownImage.image = #imageLiteral(resourceName: "up")
                } else if stockPrice.close < lastTradeDayClose {
                    cell.view.layer.borderColor = UIColor.green.cgColor
                    cell.priceLabel.textColor = .green
                    cell.priceChangeLabel.textColor = .green
                    cell.priceChangeLabel.text = String(floor(abs(stockPrice.close - lastTradeDayClose) * 100) / 100)
                    cell.changePercentageLabel.text = String(floor(abs((stockPrice.close - lastTradeDayClose) / lastTradeDayClose) * 100 * 100) / 100) + "%"
                    cell.changePercentageLabel.textColor = .green
                    cell.updownImage.image = #imageLiteral(resourceName: "down")
                } else {
                    cell.view.layer.borderColor = UIColor.white.cgColor
                    cell.priceLabel.textColor = .white
                    cell.priceChangeLabel.textColor = .white
                    cell.changePercentageLabel.textColor = .white
                    cell.updownImage.image = nil
                }
            } else {
                cell.view.layer.borderColor = UIColor.white.cgColor
                cell.priceLabel.textColor = .white
                cell.priceChangeLabel.textColor = .white
                cell.changePercentageLabel.textColor = .white
                cell.updownImage.image = nil
            }
            
            cell.symbolLabel.text = stockPrice.symbol
            cell.priceLabel.text = String(stockPrice.close)
        }
        
        let items = Observable.changeset(from: viewModel.subscription)
        items
            .bind(to: collectionView.rx.realmChanges(dataSource))
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

