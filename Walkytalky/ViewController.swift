//
//  ViewController.swift
//  Walkytalky
//
//  Created by sutie on 2018. 9. 26..
//  Copyright © 2018년 sutie. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var tapButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    
    let viewModel = MainViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.count.asObservable().subscribe().disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        viewModel.count.asObservable()
            .subscribe(onNext: { [weak self] num in
                self?.countLabel.text = String(num)
            })
    }
    
    @IBAction func tapButtonTapped(_ sender: Any) {
        viewModel.count.value += 1
    }
}

