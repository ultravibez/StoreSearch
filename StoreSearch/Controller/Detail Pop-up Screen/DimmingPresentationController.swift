//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Matan Dahan on 18/08/2018.
//  Copyright © 2018 Matan Dahan. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    
    // stops the view from making the background black(the default)
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    // we only wanna load it once and reuse it later,
    // that's why it's lazy.
    private lazy var dimmingView = GradientView(frame: CGRect.zero)
    
    // triggered when new view controller is about to be
    // shown on the screen.
    override func presentationTransitionWillBegin() {
        // creating dimming view and making it as big as the containerView.
        dimmingView.frame = containerView!.bounds
        containerView!.insertSubview(dimmingView, at: 0)
        
        // animate backgound gradient view
        dimmingView.alpha = 0
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 1
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 0
            }, completion: nil)
        }
    }
}
