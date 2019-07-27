//
//  ViewController.swift
//  AudioRecorder
//
//  Created by Vinicius Leal on 13/07/19.
//  Copyright © 2019 Vinicius Leal. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    let defaults = UserDefaults.standard

    let audioMonitor = Microphone()
    var timeRecorded = TimeInterval()
    
    //Audio Animation
    var voiceAnimation = VoiceAnimation()
    var lastTransformScale: CGFloat = 0.0 //used to scale based on mic level.
    
    //Background Animation
    let backgroundLayer = CAGradientLayer()
    var backgroundIsExpanded = false
    var originalBackgroundLayerHeight = CGFloat()
    var dynamicBackgroundLayerHeight = CGFloat()
    var expandedBackgroundLayerHeight = CGFloat()
    
    //View Controller transition Animation
    let transition = PopAnimator()
    
    @IBOutlet weak var microphone: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var padlock: UIImageView!
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet var gestureToRecord: UILongPressGestureRecognizer!
    @IBOutlet var gestureToLock: UIPanGestureRecognizer!
    
    @IBAction func startsRecording(_ sender: Any) {
        
        switch gestureToRecord.state {
        case .began:
            audioMonitor.startMonitoringWithHandler({ level in
                let scaleFactor = max(0.1, CGFloat(level) + 50) / 2
                self.voiceAnimation.animateWithVoice(lastTransformScale: self.lastTransformScale, scaleFactor: scaleFactor)
                self.lastTransformScale = scaleFactor
            })
        case .ended, .failed, .cancelled:
            if timeRecorded < 5 {
                stopRecording()
            } else {
                if gestureToLock.translation(in: view).y > 0 {
                    print("pan gesture took over")
                } else {
                    stopRecording()
                }
            }
        default:
            break
        }
    }
    
    func stopRecording() {
        audioMonitor.stopMonitoring()
        timeRecorded = 1.0
        voiceAnimation.dot.removeAllAnimations()
        timerLabel.text = "Tap and hold the microphone to record"
        self.padlock.tintColor = Constants.pinkColor
        self.padlock.image = UIImage(named: "padlock-open")
        padlock.alpha = 0
        pauseButton.alpha = 0
        listButton.tintColor = Constants.pinkColor
        backgroundIsExpanded = false
        backgroundLayer.resizeAndMove(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: originalBackgroundLayerHeight), animated: true)
    }
    
    @IBAction func dragToLock(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        dynamicBackgroundLayerHeight = originalBackgroundLayerHeight
        
        if timeRecorded >= 5 {
            switch sender.state {
            case .began, .changed:
                if backgroundIsExpanded == false {
                    dynamicBackgroundLayerHeight += translation.y
                    if dynamicBackgroundLayerHeight > originalBackgroundLayerHeight {
                        backgroundLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: dynamicBackgroundLayerHeight)
                        if dynamicBackgroundLayerHeight >= padlock.frame.midY {
                            backgroundLayer.resizeAndMove(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: expandedBackgroundLayerHeight), animated: true, duration: 0.6)
                            
                            let pulseCircle = PulsingCircle(numberOfPulses: 1, radius: 50, position: self.padlock.center)
                            self.view.layer.insertSublayer(pulseCircle, below: self.padlock.layer)
                            UIView.animate(withDuration: 0.3, animations: {
                                self.padlock.tintColor = .white
                                self.padlock.image = UIImage(named: "padlock-close")
                                
                            }) { (sucess) in
                                self.listButton.tintColor = .white
                                self.pauseButton.alpha = 1
                                UIView.animate(withDuration: 1.5, animations: {
                                    self.padlock.alpha = 0
                                })
                            }
                            backgroundIsExpanded = true
                        }
                    }
                }
            case .ended, .cancelled, .failed:
                if backgroundIsExpanded == false {
                    stopRecording()
                }
            default:
                break
            }
        }
    }
    
    @IBAction func recordingPaused(_ sender: Any) {
        listButton.tintColor = Constants.pinkColor
        stopRecording()
    }
    
    func setupBackgroundLayer() {
        view.layer.insertSublayer(backgroundLayer, below: voiceAnimation.replicator)
        
        for sview in [microphone, listButton, padlock, pauseButton] {
            view.bringSubviewToFront(sview!)
        }
        originalBackgroundLayerHeight = microphone.frame.maxY - 20
        expandedBackgroundLayerHeight = view.frame.height
        
        microphone.tintColor = .white
        padlock.tintColor = Constants.pinkColor
        padlock.alpha = 0
        pauseButton.alpha = 0
        listButton.tintColor = Constants.pinkColor
        
        view.bringSubviewToFront(timerLabel)
        backgroundLayer.colors = [Constants.pinkGradientTop, Constants.pinkGradientBottom]
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: originalBackgroundLayerHeight)
        backgroundLayer.shadowColor = Constants.pinkGradientTop
        backgroundLayer.shadowOffset = .zero
        backgroundLayer.shadowRadius = 18
        backgroundLayer.shadowOpacity = 1
        backgroundLayer.cornerRadius = 120
        backgroundLayer.masksToBounds = false
        backgroundLayer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        voiceAnimation.setupAudioAnimation(view: view)
        setupBackgroundLayer()
        
        // Set gesture recognizers delegates
        gestureToLock.delegate = self
        gestureToRecord.delegate = self
        
        // Set audio delegate
        audioMonitor.delegate = self
    }
    
    @IBAction func didTapList(_ sender: Any) {
        
        //Present details view controller
        let recordingsList = storyboard!.instantiateViewController(withIdentifier: "RecordingsViewController") as! RecordingsViewController
        recordingsList.transitioningDelegate = self
        present(recordingsList, animated: true, completion: nil)
        
        guard let recorder = audioMonitor.recorder else { return }
        if recorder.isRecording {
            stopRecording()
        }
    }
}

