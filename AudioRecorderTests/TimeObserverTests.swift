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
    
}

class TimeObserverTests: XCTestCase {
    
    func test_init_doesNotObserve() {
        let counter = Counter()
        _ = TimeObserver()
        
        XCTAssertEqual(counter.count, 0)
    }
    
    // MARK: - Helpers
    
    private class Counter {
        private(set) var count: Int = 0
        
    }
}
