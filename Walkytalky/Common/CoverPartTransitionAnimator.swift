//
//  CoverPartTransitionAnimator.swift
//  Walkytalky
//
//  Created by 안덕환 on 13/10/2018.
//  Copyright © 2018 sutie. All rights reserved.
//

import Foundation
import UIKit


class CoverPartTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum TransitionMode {
        case present
        case dismiss
    }
    
    var transitionMode: TransitionMode = .present
    
    convenience init(transitionMode: TransitionMode) {
        self.init()
        self.transitionMode = transitionMode
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        switch transitionMode {
        case .present:
            return 0.3
        case .dismiss:
            return 0.2
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch transitionMode {
        case .present:
            animatePresentTransition(using: transitionContext)
        case .dismiss:
            animateDismissTransition(using: transitionContext)
        }
    }
    
    private func animatePresentTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toVC.view)
        
        let duration = transitionDuration(using: transitionContext)
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut)
        
        toVC.view.frame.origin.x = -UIScreen.main.bounds.width
        animator.addAnimations {
            fromVC.view.alpha = 0.2
            toVC.view.frame.origin.x = 0
        }
        animator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        animator.startAnimation()
    }
    
    private func animateDismissTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                return
        }
        
        let duration = transitionDuration(using: transitionContext)
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut)
        
        animator.addAnimations {
            fromVC.view.frame.origin.x = -UIScreen.main.bounds.width
            toVC.view.alpha = 1
        }
        animator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        animator.startAnimation()
    }
}
