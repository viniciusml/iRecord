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
    private let onPermissionDenied: () -> Void
    
    init(session: Session = AVAudioSession.sharedInstance(), onPermissionDenied: @escaping () -> Void) throws {
        self.session = session
        self.onPermissionDenied = onPermissionDenied
        
        try session.setCategory(.playAndRecord, mode: .default, options: [])
    }
    
    func requestPermissionIfNeeded() {
        guard session.needsRecordPermissionRequest else { return }
        
        session.requestRecordPermission { permission in
            if permission == false {
                self.onPermissionDenied()
            }
        }
    }
}

class AudioSessionTests: XCTestCase {
    
    func test_init_requestsPermissionWhenNotGranted() {
        let (session1, sut1) = makeSUT(.undetermined)
        sut1.requestPermissionIfNeeded()
        XCTAssertEqual(session1.requestRecordPermissionCount, 1)
        
        let (session2, sut2) = makeSUT(.denied)
        sut2.requestPermissionIfNeeded()
        XCTAssertEqual(session2.requestRecordPermissionCount, 1)

        let (session3, sut3) = makeSUT(.granted)
        sut3.requestPermissionIfNeeded()
        XCTAssertEqual(session3.requestRecordPermissionCount, 0)
    }
    
    func test_permissionNotGranted_delegatesMessage() {
        var permissionCallbackCalled = false
        let (session, sut) = makeSUT(.undetermined, onPermissionDenied: {
            permissionCallbackCalled.toggle()
        })
        
        sut.requestPermissionIfNeeded()
        session.completeWithPermission(false)
        
        XCTAssertTrue(permissionCallbackCalled)
    }
    
    func test_permissionGranted_doesNotDelegateMessage() {
        var permissionCallbackCalled = false
        let (session, sut) = makeSUT(.undetermined, onPermissionDenied: {
            permissionCallbackCalled.toggle()
        })
        
        sut.requestPermissionIfNeeded()
        session.completeWithPermission(true)
        
        XCTAssertFalse(permissionCallbackCalled)
    }
    
    func test_init_failsToSetCategory() {
        let session = AVAudioSessionSpy(.granted)
        session.stubbedError = NSError(domain: "initialisation error", code: 0)
        
        XCTAssertThrowsError(try AudioSession(session: session, onPermissionDenied: {}))
    }
    
    func test_init_setsCategoty() throws {
        let (session, _) = makeSUT(.granted)
        
        XCTAssertEqual(session.categories.count, 1)
        let tuple = try XCTUnwrap(session.categories.first)
        
        XCTAssertEqual(tuple.category, .playAndRecord)
        XCTAssertEqual(tuple.mode, .default)
        XCTAssertTrue(tuple.options.isEmpty)
    }
    
    // MARK: Helpers
    
    private func makeSUT(_ permission: AVAudioSession.RecordPermission, onPermissionDenied: @escaping () -> Void = {}) -> (AVAudioSessionSpy, AudioSession) {
        let session = AVAudioSessionSpy(permission)
        let sut = try! AudioSession(session: session, onPermissionDenied: onPermissionDenied)
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
        
        func completeWithPermission(_ response: Bool, at index: Int = 0) {
            requestRecordPermissionResponses[index](response)
        }
        
        func setCategory(_ category: AVAudioSession.Category, mode: AVAudioSession.Mode, options: AVAudioSession.CategoryOptions) throws {
            if let error = stubbedError {
                throw error
            }
            categories.append((category, mode, options))
        }
    }
}

