//
//  ViewController.swift
//  Walkytalky
//
//  Created by sutie on 2018. 9. 26..
//  Copyright © 2018년 sutie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class MainViewController: UIViewController {
    
    
    @IBOutlet weak var recordBackColoredView: UIView!
    @IBOutlet weak var recordBtnBackView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    
    let viewModel = MainViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        recordButton.rx.tap
//        bindViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        viewModel.count.asObservable().subscribe().disposed(by: disposeBag)
    }
    
    private func setUI() {
        recordBackColoredView.cornerRadius = recordBackColoredView.frame.height * 0.5
        recordBtnBackView.cornerRadius = recordBtnBackView.frame.height * 0.5
        recordButton.cornerRadius = recordButton.frame.height * 0.5
    }
    
//
//    private func bindViewModel() {
//        viewModel.count.asObservable()
//            .subscribe(onNext: { [weak self] num in
//                self?.countLabel.text = String(num)
//            })
//    }
//
//    @IBAction func tapButtonTapped(_ sender: Any) {
//        viewModel.count.value += 1
//    }
}

