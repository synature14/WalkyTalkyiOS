//
//  Extensions.swift
//  Walkytalky
//
//  Created by sutie on 05/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
   
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            self.clipsToBounds = true
            layer.cornerRadius = newValue
        }
    }
}
