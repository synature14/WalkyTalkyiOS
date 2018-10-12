//
//  Bindable.swift
//  Walkytalky
//
//  Created by sutie on 2018. 9. 26..
//  Copyright © 2018년 sutie. All rights reserved.
//

import Foundation
import UIKit

protocol Bindable: class {
    associatedtype ViewModelType
    var viewModel: ViewModelType! { get set }
    func bindViewModel()
}

extension Bindable where Self: UIViewController {
    func bindViewModel(to viewModel: Self.ViewModelType) {
        self.viewModel = viewModel
        loadViewIfNeeded()
        bindViewModel()
    }
}
