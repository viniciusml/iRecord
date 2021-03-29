//
//  TimeObserverTests.swift
//  AudioRecorderTests
//
//  Created by Vinicius Moreira Leal on 28/03/2021.
//  Copyright © 2021 Vinicius Leal. All rights reserved.
//

import XCTest

protocol ScheduledTimer {
    static func scheduledTimer(timeInterval ti: TimeInterval, target aTarget: Any, selector aSelector: Selector, userInfo: Any?, repeats yesOrNo: Bool) -> Timer
}

extension Timer: ScheduledTimer {}

class TimeObserver {
    private let timeProvider: Timer.Type
    var observerCallback: () -> Void = {}
    
    init(timeProvider: Timer.Type = Timer.self) {
        self.timeProvider = timeProvider
    }
    
    func observe(timeInterval: TimeInterval = 0.02, shouldRepeat: Bool = true) {
        timeProvider.scheduledTimer(withTimeInterval: timeInterval, repeats: shouldRepeat, block: { _ in
            self.observerCallback()
        })
    }
}

class TimeObserverTests: XCTestCase {
    
    func test_init_doesNotObserve() {
        let counter = Counter()
        _ = TimeObserver()
        
        XCTAssertEqual(counter.count, 0)
    }
    
    func test_observe_startsObserving() {
        let counter = Counter()
        let sut = TimeObserver()
        let exp = expectation(description: "wait for timer to fire")
        
        sut.observerCallback = {
            exp.fulfill()
            counter.increaseCount()
        }
        sut.observe(timeInterval: 1.0)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(counter.count, 1)
    }
    
    // MARK: - Helpers
    
    private class TimerSpy: Timer {
        
        var block: ((Timer) -> Void)!
        
        static var currentTimer: TimerSpy!
        
        override func fire() {
            block(self)
        }
        
        override open class func scheduledTimer(
            withTimeInterval interval: TimeInterval,
            repeats: Bool,
            block: @escaping (Timer) -> Void) -> Timer {
            
            let mockTimer = TimerSpy()
            mockTimer.block = block
            
            TimerSpy.currentTimer = mockTimer
            
            return mockTimer
        }
    }
    
    private class Counter {
        private(set) var count: Int = 0
        
        func increaseCount() {
            count += 1
        }
    }
}
