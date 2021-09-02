
import Foundation
import XCTest

/// Allows creating and evaluating asynchronous assertions with synchronous-like syntax. When called, it stops the test
/// execution and waits for the assertions to be fulfilled.
///
/// There are two ways of using `AssertAsync`:
///   - For single assertions, you can use it directly using the convenience static function helpers:
///   ```
///   func test() {
///     // ...
///     AssertAsync.willBeNil(expression)
///   }
///   ```
///
///   - If you have multiple assertions you want to evaluate at the same time, you can use the following syntax:
///   ```
///   func test() {
///     // ...
///     AssertAsync {
///         Assert.willBeNil(expression1)
///         Assert.staysFalse(expression2)
///     }
///   }
///   ```
public struct AssertAsync {
    // This shouldn't be needed and it's just a workaround for https://bugs.swift.org/browse/SR-11628. Remove when possible.
    @discardableResult
    public init(@AssertionBuilder singleBuilder: () -> Assertion) {
        self.init(builder: {
            let built = singleBuilder()
            return [built]
        })
    }

    @discardableResult
    public init(@AssertionBuilder builder: () -> [Assertion]) {
        var assertions = builder()
        let startTimestamp = Date().timeIntervalSince1970

        while assertions.isEmpty == false {
            let elapsedTime = Date().timeIntervalSince1970 - startTimestamp
            // Evaluate and remove idle assertions
            assertions = assertions.filter { $0.evaluate(elapsedTime: elapsedTime) == .active }
            _ = XCTWaiter.wait(for: [.init()], timeout: evaluationPeriod)
        }
    }
}
