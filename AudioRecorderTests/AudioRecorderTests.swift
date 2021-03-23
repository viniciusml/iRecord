//
//  AudioRecorderTests.swift
//  AudioRecorderTests
//
//  Created by Vinicius Moreira Leal on 23/03/2021.
//  Copyright © 2021 Vinicius Leal. All rights reserved.
//

import AVFoundation
import XCTest

protocol Recorder: class {
    var isMeteringEnabled: Bool { get set }
    var delegate: AVAudioRecorderDelegate? { get set }
    init(url: URL, settings: [String : Any]) throws
    @discardableResult func record() -> Bool
    @discardableResult func prepareToRecord() -> Bool
}

extension AVAudioRecorder: Recorder {}

struct AudioRecorderFactory {
    private static let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    static func make(with url: URL, settings: [String: Any] = settings) throws -> Recorder {
        try AVAudioRecorder(url: url, settings: settings)
    }
}

class AudioRecorder: NSObject {
    private let recorder: Recorder
    
    init(recorder: Recorder) {
        self.recorder = recorder
        super.init()
        
        self.recorder.delegate = self
    }
    
    func start() {
        recorder.record()
        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {}

class AudioRecorderTests: XCTestCase {
    
    func test_init_setsDelegate() throws {
        let recorder = try AudioRecorderSpy()
        let sut = AudioRecorder(recorder: recorder)
        
        XCTAssertTrue(recorder.delegate === sut)
    }
    
    func test_start_forwardsMessage() throws {
        let recorder = try AudioRecorderSpy()
        let sut = AudioRecorder(recorder: recorder)
        
        sut.start()
        
        XCTAssertEqual(recorder.messages, [.record, .prepareToRecord])
        XCTAssertTrue(recorder.isMeteringEnabled)
    }
}

class AudioRecorderSpy: Recorder {
    enum Message {
        case record, prepareToRecord
    }
    
    private let url: URL
    private let settings: [String : Any]
    var isMeteringEnabled: Bool = false
    
    var delegate: AVAudioRecorderDelegate?
    
    private(set) var messages = [Message]()
    
    required init(url: URL = URL.any, settings: [String: Any] = [:]) throws {
        self.url = url
        self.settings = settings
    }
    
    func record() -> Bool {
        messages.append(.record)
        return true
    }
    
    func prepareToRecord() -> Bool {
        messages.append(.prepareToRecord)
        return true
    }
}

extension URL {
    static var any: URL {
        URL(string: "http://any-url.com")!
    }
}
