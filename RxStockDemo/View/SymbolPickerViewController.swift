//
//  SymbolPickerViewController.swift
//  RxStockDemo
//
//  Created by Frank on 2017/11/17.
//  Copyright © 2017 Frank. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift
import RxRealmDataSources
import DZNEmptyDataSet

class SymbolPickerViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let bag = DisposeBag()
    private var viewModel: SymbolPickerViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        viewModel = SymbolPickerViewModel()
        
        bindUI()
    }
    
    private func bindUI() {
        bindTableView("")
        
        let input = searchBar.rx.text.orEmpty
            .asObservable()
            .share()

        input.throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged { (string1, string2) in
                return string1 == string2
            }
            .subscribe(onNext: { [weak self] (term) in
                self?.bindTableView(term)
            })
            .disposed(by: bag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                if let cell = self?.tableView.cellForRow(at: indexPath) {
                    let realm = try! Realm()
                    
                    try! realm.write {
                        let stockPortfolio = StockPortfolio()
                        stockPortfolio.symbol = cell.detailTextLabel!.text!
                        
                        realm.add(stockPortfolio, update: true)
                    }
                    
                    self?.navigationController?.popViewController(animated: true)
                }
            })
        .disposed(by: bag)
    }

    private func bindTableView(_ term: String) {
        let dataSource = RxTableViewRealmDataSource<StockSymbol>(cellIdentifier: "SymbolCell", cellType: UITableViewCell.self) { cell, indexPath, symbol in
            cell.textLabel?.text = symbol.name
            cell.detailTextLabel?.text = symbol.symbol
            
            let separatorLine = UIImageView(frame: CGRect(x: 8, y: 64, width: cell.frame.width - 16, height: 0.5))
            separatorLine.backgroundColor = .gray
            cell.contentView.addSubview(separatorLine)
        }

        var objects: Results<StockSymbol>

        if term.isEmpty {
            objects = viewModel.symbols
        } else {
            objects = viewModel.symbols
                .filter("symbol CONTAINS[c] '\(term)' or name CONTAINS[c] '\(term)'")
        }

        let objectsObservable = Observable.changeset(from: objects, synchronousStart: true)
            .share()

        objectsObservable
            .bind(to: tableView.rx.realmChanges(dataSource))
            .disposed(by: bag)
    }
}

extension SymbolPickerViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Data"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return #imageLiteral(resourceName: "NoData")
    }
}
