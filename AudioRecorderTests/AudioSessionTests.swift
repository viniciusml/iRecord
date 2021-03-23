//
//  AudioSessionTests.swift
//  AudioSessionTests
//
//  Created by Vinicius Moreira Leal on 22/03/2021.
//  Copyright © 2021 Vinicius Leal. All rights reserved.
//

import AVFoundation
import XCTest

protocol Session {
    var recordPermission: AVAudioSession.RecordPermission { get }
    func requestRecordPermission(_ response: @escaping (Bool) -> Void)
    func setCategory(_ category: AVAudioSession.Category, mode: AVAudioSession.Mode, options: AVAudioSession.CategoryOptions) throws
}

extension AVAudioSession: Session {}

extension Session {
    var needsRecordPermissionRequest: Bool {
        recordPermission != .granted
    }
}

class AudioSession {
    private let session: Session
    
    init(session: Session = AVAudioSession.sharedInstance()) throws {
        self.session = session
        
        requestPermissionIfNeeded()
        try session.setCategory(.playAndRecord, mode: .default, options: [])
    }
    
    private func requestPermissionIfNeeded() {
        guard session.needsRecordPermissionRequest else { return }
        
        session.requestRecordPermission { _ in }
    }
}

class AudioSessionTests: XCTestCase {
    
    func test_init_requestsPermissionWhenNotGranted() {
        let (session1, _) = makeSUT(.undetermined)
        
        XCTAssertEqual(session1.requestRecordPermissionCount, 1)
        
        let (session2, _) = makeSUT(.denied)

        XCTAssertEqual(session2.requestRecordPermissionCount, 1)

        let (session3, _) = makeSUT(.granted)

        XCTAssertEqual(session3.requestRecordPermissionCount, 0)
    }
    
    func test_init_failsToSetCategory() {
        let session = AVAudioSessionSpy(.granted)
        session.stubbedError = NSError(domain: "initialisation error", code: 0)
        
        XCTAssertThrowsError(try AudioSession(session: session))
    }
    
    // MARK: Helpers
    
    private func makeSUT(_ permission: AVAudioSession.RecordPermission) -> (AVAudioSessionSpy, AudioSession) {
        let session = AVAudioSessionSpy(permission)
        let sut = try! AudioSession(session: session)
        return (session, sut)
    }
    
    private class AVAudioSessionSpy: Session {
        private let stubbedPermission: AVAudioSession.RecordPermission
        private var requestRecordPermissionResponses = [((Bool) -> Void)]()
        private(set) var categories = [(category: AVAudioSession.Category, mode: AVAudioSession.Mode, options: AVAudioSession.CategoryOptions)]()
        var stubbedError: Error?
        
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
        
        func setCategory(_ category: AVAudioSession.Category, mode: AVAudioSession.Mode, options: AVAudioSession.CategoryOptions) throws {
            if let error = stubbedError {
                throw error
            }
            categories.append((category, mode, options))
        }
    }
}

