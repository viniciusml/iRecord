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

extension AudioSession {
    var needsRecordPermissionRequest: Bool {
        recordPermission != .granted
    }
}

class Recorder {
    private let session: AudioSession
    
    init(session: AudioSession = AVAudioSession.sharedInstance()) {
        self.session = session
        
        if session.needsRecordPermissionRequest {
            session.requestRecordPermission { _ in }
        }
    }
}

class RecorderTests: XCTestCase {
    
    func test_init_requestsPermissionWhenNotGranted() {
        let (session1, _) = makeSUT(.undetermined)
        
        XCTAssertEqual(session1.requestRecordPermissionCount, 1)
        
        let (session2, _) = makeSUT(.denied)

        XCTAssertEqual(session2.requestRecordPermissionCount, 1)

        let (session3, _) = makeSUT(.granted)

        XCTAssertEqual(session3.requestRecordPermissionCount, 0)
    }
    
    // MARK: Helpers
    
    private func makeSUT(_ permission: AVAudioSession.RecordPermission) -> (AudioSessionSpy, Recorder) {
        let session = AudioSessionSpy(permission)
        let sut = Recorder(session: session)
        return (session, sut)
    }
    
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

