//
//  VoiceAnimation.swift
//  AudioRecorder
//
//  Created by Vinicius Leal on 20/07/19.
//  Copyright © 2019 Vinicius Leal. All rights reserved.
//

import UIKit

class VoiceAnimation: NSObject {
    let replicator = CAReplicatorLayer()
    let dot = CALayer()
    let dotLength: CGFloat = 3.0
    let dotOffset: CGFloat = 11.0

    func setupAudioAnimation(view: UIView) {
        view.layer.addSublayer(replicator)
        replicator.addSublayer(dot)

        replicator.frame = CGRect(x: view.bounds.minY - 5, y: view.bounds.minY + 90, width: view.bounds.width, height: 100)
        replicator.instanceCount = Int(view.frame.size.width / dotOffset)
        replicator.instanceTransform = CATransform3DMakeTranslation(-dotOffset, 0.0, 0.0)
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
        let scale = CABasicAnimation(keyPath: "transform")
        scale.toValue = NSValue(caTransform3D: CATransform3DIdentity)
        scale.duration = 0.33
        scale.isRemovedOnCompletion = false
        scale.fillMode = CAMediaTimingFillMode.forwards
        dot.add(scale, forKey: nil)
    }

    func animateWithVoice(lastTransformScale: CGFloat, scaleFactor: CGFloat) {
        dot.backgroundColor = UIColor.white.cgColor
        dot.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor

        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 1.0
        fade.toValue = 0.2
        fade.duration = 0.33
        fade.beginTime = CACurrentMediaTime() + 0.33
        fade.repeatCount = .infinity
        fade.autoreverses = true
        fade.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        dot.add(fade, forKey: "dotOpacity")

        let scale = CABasicAnimation(keyPath: "transform.scale.y")
        scale.fromValue = lastTransformScale
        scale.toValue = scaleFactor
        scale.duration = 0.1
        scale.isRemovedOnCompletion = false
        scale.fillMode = CAMediaTimingFillMode.forwards
        dot.add(scale, forKey: nil)
    }
}
