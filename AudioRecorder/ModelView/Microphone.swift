//
//  Microphone.swift
//  AudioRecorder
//
//  Created by Vinicius Leal on 13/07/19.
//  Copyright © 2019 Vinicius Leal. All rights reserved.
//

import AVFoundation

class Microphone: NSObject, AVAudioRecorderDelegate {
    var recorder: AVAudioRecorder!
    private var timer: Timer?
    private var levelsHandler: ((Float) -> Void)?

    var timeRecorded: TimeInterval = 1.0
    var timeAsString = String()
    var numberOfRecordings = 0
    var audioRec: Audio!
    var audiosRecorded = [Audio]()

    let defaults = UserDefaults.standard

    // Delegate to update label
    weak var delegate: MicrophoneDelegate?

    override init() {
        super.init()

        loadData()

        let audioSession = AVAudioSession.sharedInstance()

        if audioSession.recordPermission != .granted {
            audioSession.requestRecordPermission { success in print("microphone permission: \(success)") }
        }

        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
        } catch {
            print("Couldn't initialize the mic input")
        }
    }

    func loadData() {
        guard let retrievedData = defaults.object(forKey: "SavedArray") as? NSData else {
            print("'storedAudios' not found in UserDefaults")
            return
        }

        guard let retrievedArray = NSKeyedUnarchiver.unarchiveObject(with: retrievedData as Data) as? [Audio]
        else {
            print("Could not unarchive from retrievedData")
            return
        }
        audiosRecorded = retrievedArray
    }

    func startMonitoringWithHandler(_ handler: ((Float) -> Void)?) {
        levelsHandler = handler

        // start meters
        timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(Microphone.handleMicLevel(_:)), userInfo: nil, repeats: true)
        startAudioRecording()
    }

    func stopMonitoring() {
        levelsHandler = nil
        timer?.invalidate()
        timeRecorded = 1.0
        finishRecording(success: true)
    }

    func startAudioRecording() {
        numberOfRecordings = defaults.integer(forKey: "numberOfRecordings")
        numberOfRecordings += 1

        let numberOfRecString = String(numberOfRecordings)
        let recordingName = "recording" + numberOfRecString + ".m4a"

        let audioFilename = getDocumentsDirectory().appendingPathComponent(recordingName)

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            recorder.delegate = self
            recorder.record()

            audioRec = Audio(name: "Recording " + numberOfRecString, duration: "duration", url: audioFilename.absoluteURL, storedName: recordingName)

        } catch {
            finishRecording(success: false)
        }

        if let recorder = recorder {
            // start observing mic levels
            recorder.prepareToRecord()
            recorder.isMeteringEnabled = true
        }
    }

    func finishRecording(success: Bool) {
        let audioDuration = recorder.currentTime

        recorder.stop()

        if success {
            audioRec?.duration = timeString(time: audioDuration)
            audiosRecorded.append(Audio(name: audioRec.name, duration: audioRec.duration, url: audioRec.url, storedName: audioRec.storedName))
            do {
                let myData = try NSKeyedArchiver.archivedData(withRootObject: audiosRecorded, requiringSecureCoding: false)

                defaults.set(myData, forKey: "SavedArray")
                defaults.set(numberOfRecordings, forKey: "numberOfRecordings")
            } catch {
                print("error during archive")
            }

        } else {
            // recording failed :(
        }
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }

    @objc func handleMicLevel(_ timer: Timer) {
        recorder.updateMeters()
        levelsHandler?(recorder.averagePower(forChannel: 0))
        timeRecorded += 0.02
        timeAsString = timeString(time: timeRecorded)
        delegate?.updateTimerLabel()
    }

    func timeString(time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]

        let formattedDuration = formatter.string(from: time) ?? ""

        return formattedDuration
    }

    deinit {
        stopMonitoring()
    }
}
