//
//  ChartViewController.swift
//  RxStockDemo
//
//  Created by Frank on 2017/12/03.
//  Copyright © 2017 Frank. All rights reserved.
//

import UIKit
import Charts

class ChartViewController: UIViewController {
    @IBOutlet weak var chartView: CandleStickChartView!
    
    var symbol: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(symbol)
    }
}
