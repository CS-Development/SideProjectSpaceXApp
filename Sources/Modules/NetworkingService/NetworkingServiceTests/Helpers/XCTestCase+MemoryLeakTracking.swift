//
//  XCTestCase+MemoryLeakTracking.swift
//  NetworkingServiceTests
//
//  Created by Christian Slanzi on 26.10.21.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
    }
}
