//
//  PopAnimator.swift
//  AudioRecorder
//
//  Created by Vinicius Leal on 22/07/19.
//  Copyright © 2019 Vinicius Leal. All rights reserved.
//

import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 1.0
    var presenting = true
    var originFrame = CGRect.zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let recListView = presenting ? toView : transitionContext.view(forKey: .from)!
        
        let initialFrame = presenting ? originFrame : recListView.frame
        let finalFrame = presenting ? recListView.frame : originFrame
        
        let xScaleFactor = presenting ?
            initialFrame.width / finalFrame.width :
            finalFrame.width / initialFrame.width
        
        let yScaleFactor = presenting ?
            initialFrame.height / finalFrame.height :
            finalFrame.height / initialFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        
        if presenting {
            recListView.transform = scaleTransform
            recListView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
            recListView.clipsToBounds = true
        }
        
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(recListView)
        
        UIView.animate(withDuration: duration, delay:0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, animations: {
            recListView.transform = self.presenting ?
            CGAffineTransform.identity : scaleTransform
            recListView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            },
            completion: { _ in
            transitionContext.completeTransition(true)
            }
        )
    }
    

}
