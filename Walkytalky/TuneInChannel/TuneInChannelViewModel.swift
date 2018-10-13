//
//  OptionsViewModel.swift
//  Walkytalky
//
//  Created by 안덕환 on 12/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import Foundation
import RxSwift

class TuneInChannelViewModel {
    
    enum ViewAction {
        case dismiss
    }
    
    let viewAction = PublishSubject<ViewAction>()
    
    func requestDismiss() {
        viewAction.onNext(.dismiss)
    }
}
