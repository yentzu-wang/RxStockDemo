//
//  SectorViewController.swift
//  RxStockDemo
//
//  Created by Frank on 2017/12/06.
//  Copyright © 2017 Frank. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift
import RxRealmDataSources
import DZNEmptyDataSet

class SectorViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let bag = DisposeBag()
    private let viewModel = SectorViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        bindUI()
    }
    
    private func bindUI() {
        bindTableView()
    }
    
    private func bindTableView() {
        let dataSource = RxTableViewRealmDataSource<SectorPerformance>(cellIdentifier: "SectorCell", cellType: SectorTableViewCell.self) { (cell, indexPath, sectorPerformance) in
            cell.sectorLabel.text = sectorPerformance.sector
            cell.percentageLabel.text = sectorPerformance.changePercentage
            
            let percentage = Double(sectorPerformance.changePercentage.dropLast())
            
            if let percentage = percentage {
                if percentage > 0 {
                    cell.percentageLabel.textColor = .red
                } else if percentage < 0 {
                    cell.percentageLabel.textColor = .green
                } else {
                    cell.percentageLabel.textColor = .white
                }
            }
            
            let separatorLine = UIImageView(frame: CGRect(x: 8, y: cell.bounds.maxY, width: cell.frame.width - 16, height: 0.5))
            separatorLine.backgroundColor = .gray
            cell.contentView.addSubview(separatorLine)
        }
        
        let objects = viewModel.sectors
        
        let objectsObservable = Observable.changeset(from: objects, synchronousStart: true)
            .share()
        
        objectsObservable
            .bind(to: tableView.rx.realmChanges(dataSource))
            .disposed(by: bag)
    }
}

extension SectorViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Data"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return #imageLiteral(resourceName: "NoData")
    }
}
