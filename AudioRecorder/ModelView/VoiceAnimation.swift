//
//  VoiceAnimation.swift
//  AudioRecorder
//
//  Created by Vinicius Leal on 20/07/19.
//  Copyright © 2019 Vinicius Leal. All rights reserved.
//

import UIKit

class VoiceAnimation: NSObject {
    typealias CATransform3DTranslationFactory = (_ tx: CGFloat, _ ty: CGFloat, _ tz: CGFloat) -> CATransform3D
    
    let replicator = CAReplicatorLayer()
    let dot: ScalableCALayerProtocol
    let dotLength: CGFloat = 3.0
    let dotOffset: CGFloat = 11.0
    private let makeTranslation: CATransform3DTranslationFactory
    
    init(makeTranslation: @escaping CATransform3DTranslationFactory = CATransform3DMakeTranslation, dot: ScalableCALayerProtocol = ScalableCALayer()) {
        self.makeTranslation = makeTranslation
        self.dot = dot
        super.init()
    }

    func setupAudioAnimation(view: UIView) {
        view.layer.addSublayer(replicator)
        replicator.addSublayer(dot)

        replicator.frame = CGRect(x: view.bounds.minY - 5, y: view.bounds.minY + 90, width: view.bounds.width, height: 100)
        replicator.instanceCount = Int(view.frame.size.width / dotOffset)
        replicator.instanceTransform = makeTranslation(-dotOffset, 0.0, 0.0)
        replicator.instanceDelay = 0.04

        dot.frame = CGRect(
            x: replicator.frame.size.width - dotLength,
            y: replicator.position.y,
            width: dotLength,
            height: dotLength)

        dot.backgroundColor = UIColor.white.cgColor
        dot.borderColor = UIColor.white.cgColor
        dot.borderWidth = 0.5
        dot.cornerRadius = 0.5
    }

    func endSpeaking() {
        dot.backgroundColor = UIColor.clear.cgColor
        dot.borderColor = UIColor.clear.cgColor

        replicator.removeAllAnimations()
        dot.add(.transform, forKey: nil)
    }

    func animateWithVoice(lastTransformScale: CGFloat, scaleFactor: CGFloat) {
        dot.backgroundColor = UIColor.white.cgColor
        dot.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor

        dot.add(.fade, forKey: "dotOpacity")
        dot.add(.scale, with: lastTransformScale, scaleFactor: scaleFactor)
    }
}

/// Provides a way of adding a `CABasicAnimation` to a `CALayer` and transforming it before calling `.add` on `CALayer` class.
///
/// This is a workaround in order to be able to unit test the process of adding an animation, specifically in the case of an animation with injected values (currently used in this project in `.scale` property).
/// In order to inject values, the animation was defined as a static method, but because `CAAnimation`'s conformance to `Equatable` seem to rely on memory addresses rather than on properties and their values, the assertion would fail.
/// See reference: test_animateWithVoice_addsAnimations
///
/// The solution was to make it a static property rather than a static method and to provide a way of transforming this animation on a closure. This way, the tests assert on the added animation and can assert on the transformed values as well. Hence, `ScalableCALayer`.
protocol ScalableCALayerProtocol: CALayer {
    func add(_ anim: CABasicAnimation, with lastTransformScale: CGFloat, scaleFactor: CGFloat)
}

final class ScalableCALayer: CALayer, ScalableCALayerProtocol {
    
    func add(_ anim: CABasicAnimation, with lastTransformScale: CGFloat, scaleFactor: CGFloat) {
        add(anim.with(lastTransformScale, scaleFactor), forKey: nil)
    }
}

public extension CAAnimation {
    
    static var transform: CAAnimation = {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.toValue = NSValue(caTransform3D: CATransform3DIdentity)
        animation.duration = 0.33
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        return animation
    }()
    
    static var fade: CAAnimation = {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.2
        animation.duration = 0.33
        animation.beginTime = CACurrentMediaTime() + 0.33
        animation.repeatCount = .infinity
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        return animation
    }()
    
    static var scale: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.scale.y")
        animation.duration = 0.1
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        return animation
    }()
}

private extension CABasicAnimation {
    
    func with(_ lastTransformScale: CGFloat, _ scaleFactor: CGFloat) -> CAAnimation {
        self.fromValue = lastTransformScale
        self.toValue = scaleFactor
        return self
    }
}
