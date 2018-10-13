//
//  OptionViewController.swift
//  Walkytalky
//
//  Created by sutie on 05/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import UIKit

class TuneViewController: UIViewController, Bindable {
    typealias ViewModelType = TuneViewModel
    
    var viewModel: TuneViewModel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func bindViewModel() {
        
    }
}
