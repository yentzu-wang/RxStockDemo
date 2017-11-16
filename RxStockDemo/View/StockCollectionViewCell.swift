//
//  StockCollectionViewCell.swift
//  RxStockDemo
//
//  Created by Frank on 2017/11/16.
//  Copyright © 2017 Frank. All rights reserved.
//

import UIKit

class StockCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var changePercentageLabel: UILabel!
    @IBOutlet weak var updownImage: UIImageView!
    
    override func awakeFromNib() {
        view.layer.borderColor = UIColor.green.cgColor
        view.layer.borderWidth = 1
    }
}
