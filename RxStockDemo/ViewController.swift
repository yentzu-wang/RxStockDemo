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

class ViewController: UIViewController {
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SandPApi.shared.parseDataToRealm()
        
        
    }
}

