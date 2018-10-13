//
//  OptionViewController.swift
//  Walkytalky
//
//  Created by sutie on 05/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController, Bindable {
    typealias ViewModelType = OptionsViewModel
    
    var viewModel: OptionsViewModel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func bindViewModel() {
        
    }
}

extension OptionsViewController {
    
}
