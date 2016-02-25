//
//  ExploreCodeCoverageTests.swift
//  ExploreCodeCoverageTests
//
//  Created by Jonathan Nolen on 2/23/16.
//  Copyright © 2016 DT. All rights reserved.
//

import XCTest
@testable import ExploreCodeCoverage


class ExploreCodeCoverageTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let underTest = MyClass()
        XCTAssertEqual(underTest.greeting("bob"), "Hello bob");
    }
    
    func test2(){
        let underTest = MyClass()
        underTest.salutation()
    }
}
