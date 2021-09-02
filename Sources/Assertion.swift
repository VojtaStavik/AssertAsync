
import Foundation

/// Internal representation for assertions. Not meant to be created and used directly. If you wan't to add an assertion,
/// add a new static func to `extension Assert { }` and create the `Assertion` object inside.
public struct Assertion {
    enum State {
        case active, idle
    }

    let body: (_ elapsedTime: TimeInterval) -> State

    /// Evaluates the assertion.
    func evaluate(elapsedTime: TimeInterval) -> State {
        body(elapsedTime)
    }
}

/// Syntax sugar to make assertion code more readable:
///   `Assert.willBeTrue(expression)` vs `Assertion.willBeTrue(true)`
public typealias Assert = Assertion

@_functionBuilder
public enum AssertionBuilder {
    public static func buildBlock(_ assertion: Assertion) -> Assertion {
        assertion
    }

    public static func buildBlock(_ assertions: Assertion...) -> [Assertion] {
        assertions
    }
}
