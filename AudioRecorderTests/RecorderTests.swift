//
//  RecorderTests.swift
//  RecorderTests
//
//  Created by Vinicius Moreira Leal on 22/03/2021.
//  Copyright © 2021 Vinicius Leal. All rights reserved.
//

import AVFoundation
import XCTest

protocol AudioSession {
    var recordPermission: AVAudioSession.RecordPermission { get }
    func requestRecordPermission(_ response: @escaping (Bool) -> Void)
}

extension AVAudioSession: AudioSession {}

class Recorder {
    private let session: AudioSession
    
    init(session: AudioSession = AVAudioSession.sharedInstance()) {
        self.session = session
        
        if session.recordPermission != .granted {
            session.requestRecordPermission { _ in }
        }
    }
}

class RecorderTests: XCTestCase {
    
    func test_init_requestsPermissionWhenNotGranted() {
        let session1 = AudioSessionSpy(.undetermined)
        _ = Recorder(session: session1)
        
        XCTAssertEqual(session1.requestRecordPermissionCount, 1)
        
        let session2 = AudioSessionSpy(.denied)
        _ = Recorder(session: session2)

        XCTAssertEqual(session2.requestRecordPermissionCount, 1)

        let session3 = AudioSessionSpy(.granted)
        _ = Recorder(session: session3)

        XCTAssertEqual(session3.requestRecordPermissionCount, 0)
    }
    
    // MARK: Helpers
    
    private class AudioSessionSpy: AudioSession {
        private let stubbedPermission: AVAudioSession.RecordPermission
        private var requestRecordPermissionResponses = [((Bool) -> Void)]()
        
        var requestRecordPermissionCount: Int {
            requestRecordPermissionResponses.count
        }
        
        init(_ stubbedPermission: AVAudioSession.RecordPermission) {
            self.stubbedPermission = stubbedPermission
        }
        
        var recordPermission: AVAudioSession.RecordPermission {
            stubbedPermission
        }
        
        func requestRecordPermission(_ response: @escaping (Bool) -> Void) {
            requestRecordPermissionResponses.append(response)
        }
    }
}

