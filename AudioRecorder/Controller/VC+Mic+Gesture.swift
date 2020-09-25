//
//  VC+Mic+Gesture.swift
//  AudioRecorder
//
//  Created by Vinicius Leal on 21/07/19.
//  Copyright © 2019 Vinicius Leal. All rights reserved.
//

import Foundation
import UIKit

extension ViewController: MicrophoneDelegate, UIGestureRecognizerDelegate {
    func updateTimerLabel() {
        timerLabel.text = audioMonitor.timeAsString
        timeRecorded = audioMonitor.timeRecorded

        if timeRecorded >= 5, timeRecorded <= 5.5 {
            padlock.alpha = 1
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == gestureToLock, otherGestureRecognizer == gestureToRecord {
            return true
        }
        return false
    }
}
