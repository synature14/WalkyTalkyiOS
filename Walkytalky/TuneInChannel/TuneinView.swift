//
//  TuneinView.swift
//  Walkytalky
//
//  Created by 안덕환 on 13/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import Foundation
import UIKit


class TuneinView: UIView {
    
    private let firstControlPointView = UIView()
    private let secondControlPointView = UIView()
    private let thirdControlPointView = UIView()
    private let fourthControlPointView = UIView()
    private let fifthControlPointView = UIView()
    
    private let elasticShapeLayer = CAShapeLayer()
    
    private lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(self.updateLoop))
        displayLink.add(to: .current, forMode: .common)
        return displayLink
    }()
    
    @objc private func updateLoop() {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchPoint = touch.location(in: self)
        print("point: \(touchPoint)")
    }
}
