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
        timeProvider.scheduledTimer(withTimeInterval: timeInterval, repeats: shouldRepeat, block: { [weak self] _ in
            self?.observerCallback()
        })
    }
}

class TimeObserverTests: XCTestCase {
    
    func test_init_doesNotObserve() {
        let (_, counter) = makeSUT()
        
        XCTAssertEqual(counter.count, 0)
    }
    
    func test_observeOnce_startsObserving() {
        let (sut, counter) = makeSUT()
        let exp = expectation(description: "wait for timer to fire")
        
        sut.observerCallback = {
            exp.fulfill()
            counter.increaseCount()
        }
        sut.observe(timeInterval: 1.0)
        
        wait(for: [exp], timeout: 1.2)
        XCTAssertEqual(counter.count, 1)
    }
    
    func test_observeMultipleTimes_startsObserving() {
        let (sut, counter) = makeSUT()
        
        let exp1 = expectation(description: "wait for timer1 to fire")
        let exp2 = expectation(description: "wait for timer2 to fire")
        let exp3 = expectation(description: "wait for timer3 to fire")
        let exp4 = expectation(description: "wait for timer4 to fire")
        let allExp = [exp1, exp2, exp3, exp4]
        var expectations = allExp
        
        sut.observerCallback = {
            expectations.first?.fulfill()
            if expectations.count > 1 {
                expectations.removeFirst()
            }
            counter.increaseCount()
        }
        sut.observe(timeInterval: 0.25)
        
        wait(for: allExp, timeout: 1.2)
        XCTAssertEqual(counter.count, 4)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: TimeObserver, counter: Counter) {
        let sut = TimeObserver()
        let counter = Counter()
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(counter, file: file, line: line)
        return (sut, counter)
    }
    
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
