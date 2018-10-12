//
//  UIView+Extension.swift
//  Walkytalky
//
//  Created by 안덕환 on 12/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            self.clipsToBounds = true
            layer.cornerRadius = newValue
        }
    }
}
