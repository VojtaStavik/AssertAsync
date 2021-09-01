import XCTest

import AssertAsyncTests

var tests = [XCTestCaseEntry]()
tests += AssertAsyncTests.allTests()
XCTMain(tests)
