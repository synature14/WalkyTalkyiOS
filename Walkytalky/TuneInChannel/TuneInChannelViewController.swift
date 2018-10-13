//
//  OptionViewController.swift
//  Walkytalky
//
//  Created by sutie on 05/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TuneInChannelViewController: UIViewController, Bindable {
    typealias ViewModelType = TuneInChannelViewModel
    
    let disposeBag = DisposeBag()
    var viewModel: TuneInChannelViewModel!
    
    public static func create() -> TuneInChannelViewController {
        let sb = UIStoryboard(name: "TuneInChannel", bundle: nil)
        return sb.instantiateViewController(withIdentifier: "TuneInChannel") as! TuneInChannelViewController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGestures()
    }
    
    func bindViewModel() {
        bindViewAction()
    }
}

extension TuneInChannelViewController {
    private func bindViewAction() {
        viewModel.viewAction
            .subscribe(onNext: { [weak self] in
                switch $0 {
                case .dismiss:
                    self?.dismiss(animated: true, completion: nil)
                }
            }).disposed(by: disposeBag)
    }
}

extension TuneInChannelViewController {
    private func setGestures() {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTapOutsideRecognizer(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func handleTapOutsideRecognizer(_ gesture: UITapGestureRecognizer) {
        viewModel.requestDismiss()
    }
}
