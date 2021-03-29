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
        let expectations = [exp(1)]
        
        expect(sut: sut,
               toObserveCount: 1,
               inCounter: counter,
               forSecondInterval: 1.0,
               expectations: expectations)
    }
    
    func test_observeMultipleTimes_startsObserving() {
        let (sut, counter) = makeSUT()
        let expectations = [exp(1), exp(2), exp(3), exp(4)]
        
        expect(sut: sut,
               toObserveCount: 4,
               inCounter: counter,
               forSecondInterval: 0.25,
               expectations: expectations)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: TimeObserver, counter: Counter) {
        let sut = TimeObserver()
        let counter = Counter()
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(counter, file: file, line: line)
        return (sut, counter)
    }
    
    private func exp(_ id: Int) -> XCTestExpectation {
        expectation(description: "wait for timer to fire, count: \(id)")
    }
    
    private func expect(sut: TimeObserver, toObserveCount count: Int, inCounter counter: Counter, forSecondInterval timeInterval: TimeInterval, expectations allExp: [XCTestExpectation], file: StaticString = #filePath, line: UInt = #line) {
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
        XCTAssertEqual(counter.count, count, file: file, line: line)
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
