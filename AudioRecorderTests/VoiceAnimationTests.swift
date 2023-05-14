//
//  VoiceAnimationTests.swift
//  AudioRecorderTests
//
//  Created by Vinicius Leal on 14/05/2023.
//  Copyright © 2023 Vinicius Leal. All rights reserved.
//

@testable import AudioRecorder
import QuartzCore
import XCTest

final class VoiceAnimationTests: XCTestCase {
    
    func test_setupAudioAnimation_configuresLayers() {
        let translationFactory = CATransform3DTranslationFactorySpy()
        let sut = VoiceAnimation(makeTranslation: translationFactory.makeTranslation)
        let view = UIViewSpy()
        
        sut.setupAudioAnimation(view: view)
        
        XCTAssertEqual((view.layer as? CALayerSpy)?.log, [.addSublayer(sut.replicator)])
        XCTAssertIdentical(sut.replicator.sublayers?.last, sut.dot)
        
        XCTAssertEqual(sut.replicator.frame, CGRect(x: -5.0, y: 90.0, width: 0.0, height: 100.0))
        XCTAssertEqual(sut.replicator.instanceCount, 0)
        XCTAssertEqual(translationFactory.parameter, CATransform3DTranslationFactorySpy.Parameter(tx: -sut.dotOffset, ty: 0.0, tz: 0.0))
        XCTAssertEqual(sut.replicator.instanceDelay, 0.04)
        
        XCTAssertEqual(sut.dot.frame, CGRect(x: -3.0, y: 140.0, width: 3.0, height: 3.0))
        XCTAssertEqual(sut.dot.backgroundColor, UIColor.white.cgColor)
        XCTAssertEqual(sut.dot.borderColor, UIColor.white.cgColor)
        XCTAssertEqual(sut.dot.borderWidth, 0.5)
        XCTAssertEqual(sut.dot.cornerRadius, 0.5)
    }
}

private extension VoiceAnimationTests {
    
    final class UIViewSpy: UIView {
        
        private(set) var layerSpy = CALayerSpy()
        
        override var layer: CALayer {
            layerSpy
        }
    }
    
    final class CALayerSpy: CALayer {
        
        enum MethodCall: Equatable {
            case addSublayer(CALayer)
        }
        
        private(set) var log = [MethodCall]()
        
        override func addSublayer(_ layer: CALayer) {
            log.append(.addSublayer(layer))
            super.addSublayer(layer)
        }
    }
    
    final class CATransform3DTranslationFactorySpy {
        
        struct Parameter: Equatable {
            let tx: CGFloat
            let ty: CGFloat
            let tz: CGFloat
        }
        
        private(set) var parameter: Parameter = Parameter(tx: .zero, ty: .zero, tz: .zero)
        
        func makeTranslation(_ tx: CGFloat, _ ty: CGFloat, _ tz: CGFloat) -> CATransform3D {
            parameter = Parameter(tx: tx, ty: ty, tz: tz)
            return CATransform3D()
        }
    }
}
