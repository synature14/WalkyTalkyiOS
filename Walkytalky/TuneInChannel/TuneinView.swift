//
//  TuneinView.swift
//  Walkytalky
//
//  Created by 안덕환 on 13/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import Foundation
import UIKit


class TuneInView: UIView {
    
    private let firstControlPointView = UIView()
    private let secondControlPointView = UIView()
    private let thirdControlPointView = UIView()
    private let fourthControlPointView = UIView()
    private let fifthControlPointView = UIView()
    
    private var controlPointViews: [UIView] {
        return [
            firstControlPointView,
            secondControlPointView,
            thirdControlPointView,
            fourthControlPointView,
            fifthControlPointView
        ]
    }
    
    private let elasticShapeLayer = CAShapeLayer()
    private var selectedControlPointIndex: Int?
    
    let elasticHeight: CGFloat = 40
    let cornerDistance: CGFloat = 50
    
    private lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(self.updatesLoop))
        displayLink.add(to: .current, forMode: .common)
        return displayLink
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let controlPointIndex = calculcteControlPointIndex(from: touch.location(in: self))
        guard selectedControlPointIndex != controlPointIndex else {
            return
        }
        // 초기화 작업
        positionControlPoints()
        selectedControlPointIndex = controlPointIndex
        // 애니메이션 작업
        startUpdatesLoop()
        animateControlPoint(at: controlPointIndex)
    }
    
    private func startUpdatesLoop() {
        displayLink.isPaused = false
    }
    
    private func stopUpdatesLoop() {
        displayLink.isPaused = true
    }
    
    @objc private func updatesLoop() {
        guard let controlPointIndex = selectedControlPointIndex else {
            return
        }
        elasticShapeLayer.path = bezierPathForControlPoint(at: controlPointIndex)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupComponents()
    }
}

extension TuneInView {
    private func animateControlPoint(at index: Int) {
        guard index >= 0, index < controlPointViews.count else {
            return
        }
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 1.5,
            options: .curveEaseOut,
            animations: { [unowned self] in
                self.controlPointViews[index].center.x += self.elasticHeight
        }) { [weak self] _ in
            self?.stopUpdatesLoop()
        }
    }
    
    private func bezierPathForControlPoint(at index: Int) -> CGPath {
        guard index >= 0, index < controlPointViews.count else {
            return UIBezierPath().cgPath
        }
        
        guard let controlPoint = controlPointViews[index].layer.presentation()?.position else {
            return UIBezierPath().cgPath
        }
        
        let upperCornerPoint = CGPoint(x: frame.maxX, y: controlPoint.y + cornerDistance)
        let downCornerPoint = CGPoint(x: frame.maxX, y: controlPoint.y - cornerDistance)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.minX, y: frame.minY))
        path.addLine(to: CGPoint(x: frame.minX, y: frame.maxY))
        path.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY))
        path.addLine(to: downCornerPoint)
        path.addQuadCurve(to: upperCornerPoint, controlPoint: controlPoint)
        path.addLine(to: CGPoint(x: frame.maxX, y: frame.minY))
        path.addLine(to: CGPoint(x: frame.minX, y: frame.minY))
        return path.cgPath
    }
}

extension TuneInView {
    private func setupComponents() {
        elasticShapeLayer.fillColor = backgroundColor?.cgColor
        elasticShapeLayer.path = UIBezierPath(rect: frame).cgPath
        layer.addSublayer(elasticShapeLayer)
        
        for controlPoint in controlPointViews {
            addSubview(controlPoint)
            controlPoint.frame = CGRect(x: 0, y: 0, width: 5, height: 5)
            controlPoint.backgroundColor = .blue // 디버깅 용도
        }
        positionControlPoints()
    }
    
    private func positionControlPoints() {
        for (index, pointView) in controlPointViews.enumerated() {
            pointView.center = positionControlPoint(at: index)
        }
    }
    
    private func positionControlPoint(at index: Int) -> CGPoint {
        guard index >= 0, index < controlPointViews.count else {
            return .zero
        }
        let sectionHeight = Int(bounds.height) / controlPointViews.count
        return CGPoint(x: frame.maxX, y: CGFloat((sectionHeight / 2) + (sectionHeight * index)))
    }
    
    private func calculcteControlPointIndex(from point: CGPoint) -> Int {
        let cellHeight = bounds.height / 5
        let touchPointSection = Int(point.y / cellHeight)
        return touchPointSection
    }
}
