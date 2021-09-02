
import Foundation
import XCTest

public extension Assert {
    /// Periodically checks for the equality of the provided expressions. Fails if the expression results are not
    /// equal within the `timeout` period.
    ///
    /// - Parameters:
    ///   - expression1: The first expression to evaluate.
    ///   - expression2: The first expression to evaluate.
    ///   - timeout: The maximum time the function waits for the expression results to equal.
    ///   - message: The message to print when the assertion fails.
    ///
    /// - Warning: ⚠️ Both expressions are evaluated repeatedly during the function execution. The expressions should not have
    ///   any side effects which can affect their results.
    static func willBeEqual<T: Equatable>(
        _ expression1: @autoclosure @escaping () -> T,
        _ expression2: @autoclosure @escaping () -> T,
        timeout: TimeInterval = defaultTimeout,
        message: @autoclosure @escaping () -> String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Assertion {
        // We can't use this as the default parameter because of the string interpolation.
        var defaultMessage: String {
            "\"\(String(describing: expression1()))\" not equal to \"\(String(describing: expression2()))\""
        }

        return willBeTrue(
            expression1() == expression2(),
            timeout: timeout,
            message: message() ?? defaultMessage,
            file: file,
            line: line
        )
    }

    /// Periodically checks if the expression evaluates to `nil`. Fails if the expression result is not `nil` within
    /// the `timeout` period.
    ///
    /// - Parameters:
    ///   - expression: The expression to evaluate.
    ///   - timeout: The maximum time the function waits for the expression results to equal.
    ///   - message: The message to print when the assertion fails.
    ///
    /// - Warning: ⚠️ The expression is evaluated repeatedly during the function execution. It should not have
    ///   any side effects which can affect its result.
    static func willBeNil<T>(
        _ expression1: @autoclosure @escaping () -> T?,
        timeout: TimeInterval = defaultTimeout,
        message: @autoclosure () -> String = "Failed to become `nil`",
        file: StaticString = #file,
        line: UInt = #line
    ) -> Assertion {
        willBeTrue(
            expression1() == nil,
            timeout: timeout,
            message: "Failed to become `nil`",
            file: file,
            line: line
        )
    }

    /// Periodically checks if the expression does not evaluate to `nil`. Fails if the expression result is `nil` within
    /// the `timeout` period.
    ///
    /// - Parameters:
    ///   - expression: The expression to evaluate.
    ///   - timeout: The maximum time the function waits for the expression results to equal.
    ///   - message: The message to print when the assertion fails.
    ///
    /// - Warning: ⚠️ The expression is evaluated repeatedly during the function execution. It should not have
    ///   any side effects which can affect its result.
    static func willNotBeNil<T>(
        _ expression1: @autoclosure @escaping () -> T?,
        timeout: TimeInterval = defaultTimeout,
        message: @autoclosure () -> String = "Failed to not be `nil`",
        file: StaticString = #file,
        line: UInt = #line
    ) -> Assertion {
        willBeTrue(
            expression1() != nil,
            timeout: timeout,
            message: "Failed to not be `nil`",
            file: file,
            line: line
        )
    }

    /// Periodically checks if the expression evaluates to `TRUE`. Fails if the expression result is not `TRUE` within
    /// the `timeout` period.
    ///
    /// - Parameters:
    ///   - expression: The expression to evaluate.
    ///   - timeout: The maximum time the function waits for the expression results to equal.
    ///   - message: The message to print when the assertion fails.
    ///
    /// - Warning: ⚠️ The expression is evaluated repeatedly during the function execution. It should not have
    ///   any side effects which can affect its result.
    static func willBeTrue(
        _ expression: @autoclosure @escaping () -> Bool,
        timeout: TimeInterval = defaultTimeout,
        message: @autoclosure @escaping () -> String = "Failed to become `TRUE`",
        file: StaticString = #file,
        line: UInt = #line
    ) -> Assertion {
        Assertion { elapsedTime in
            if elapsedTime < timeout {
                if expression() {
                    // Success
                    return .idle
                }
            } else {
                // Timeout
                XCTFail(message(), file: file, line: line)
                return .idle
            }

            return .active
        }
    }

    /// Periodically checks if the expression evaluates to `FALSE`. Fails if the expression result is not `FALSE` within
    /// the `timeout` period.
    ///
    /// - Parameters:
    ///   - expression: The expression to evaluate.
    ///   - timeout: The maximum time the function waits for the expression results to equal.
    ///   - message: The message to print when the assertion fails.
    ///
    /// - Warning: ⚠️ The expression is evaluated repeatedly during the function execution. It should not have
    ///   any side effects which can affect its result.
    static func willBeFalse(
        _ expression: @autoclosure @escaping () -> Bool,
        timeout: TimeInterval = defaultTimeout,
        message: @autoclosure @escaping () -> String = "Failed to become `TRUE`",
        file: StaticString = #file,
        line: UInt = #line
    ) -> Assertion {
        willBeTrue(
            !expression(),
            timeout: timeout,
            message: "Failed to become `FALSE`",
            file: file,
            line: line
        )
    }

    /// Blocks the current test execution and asynchronously checks if the provided object can be released from the memory
    /// by assigning it to `nil`.
    ///
    /// - Warning: ⚠️ The object is destroyed during the process and the provided inout variable is set to `nil`, so you
    /// can't use it after this assertions has finished.
    ///
    /// - Parameters:
    ///   - object: The object to check for retain cycles.
    ///   - timeout: The maximum time the function waits for the object to be released.
    ///   - message: The message to print when the assertion fails.
    static func willBeReleased<T: AnyObject>(
        _ object: inout T!,
        timeout: TimeInterval = defaultTimeout,
        message: @autoclosure @escaping () -> String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Assertion {
        weak var weakObject: T? = object
        object = nil

        return willBeNil(weakObject, message: "Failed to be released from the memory.", file: file, line: line)
    }
}

public extension AssertAsync {
    /// Periodically checks if the expression evaluates to `TRUE`. Fails if the expression result is not `TRUE` within
    /// the `timeout` period.
    ///
    /// - Parameters:
    ///   - expression: The expression to evaluate.
    ///   - timeout: The maximum time the function waits for the expression results to equal.
    ///   - message: The message to print when the assertion fails.
    ///
    /// - Warning: ⚠️ Both expressions are evaluated repeatedly during the function execution. The expressions should not have
    ///   any side effects which can affect their results.
    static func willBeTrue(
        _ expression: @autoclosure () -> Bool?,
        timeout: TimeInterval = defaultTimeout,
        message: @autoclosure () -> String = "Failed to become `TRUE`",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        _ = withoutActuallyEscaping(expression) { expression in
            withoutActuallyEscaping(message) { message in

                AssertAsync {
                    Assert.willBeEqual(
                        expression(),
                        true,
                        timeout: timeout,
                        message: message(),
                        file: file,
                        line: line
                    )
                }
            }
        }
    }

    /// Periodically checks if the expression evaluates to `FALSE`. Fails if the expression result is not `FALSE` within
    /// the `timeout` period.
    ///
    /// - Parameters:
    ///   - expression: The expression to evaluate.
    ///   - timeout: The maximum time the function waits for the expression results to equal.
    ///   - message: The message to print when the assertion fails.
    ///
    /// - Warning: ⚠️ Both expressions are evaluated repeatedly during the function execution. The expressions should not have
    ///   any side effects which can affect their results.
    static func willBeFalse(
        _ expression: @autoclosure () -> Bool?,
        timeout: TimeInterval = defaultTimeout,
        message: @autoclosure () -> String = "Failed to become `FALSE`",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        _ = withoutActuallyEscaping(expression) { expression in
            withoutActuallyEscaping(message) { message in

                AssertAsync {
                    Assert.willBeEqual(
                        expression(),
                        false,
                        timeout: timeout,
                        message: message(),
                        file: file,
                        line: line
                    )
                }
            }
        }
    }

    /// Blocks the current test execution and periodically checks for the equality of the provided expressions. Fails if
    /// the expression results are not equal within the `timeout` period.
    ///
    /// - Parameters:
    ///   - expression1: The first expression to evaluate.
    ///   - expression2: The first expression to evaluate.
    ///   - timeout: The maximum time the function waits for the expression results to equal.
    ///   - message: The message to print when the assertion fails.
    ///
    /// - Warning: ⚠️ Both expressions are evaluated repeatedly during the function execution. The expressions should not have
    ///   any side effects which can affect their results.
    static func willBeEqual<T: Equatable>(
        _ expression1: @autoclosure () -> T,
        _ expression2: @autoclosure () -> T,
        timeout: TimeInterval = defaultTimeout,
        message: @autoclosure () -> String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        _ = withoutActuallyEscaping(expression1) { expression1 in
            withoutActuallyEscaping(expression2) { expression2 in
                withoutActuallyEscaping(message) { message in

                    AssertAsync {
                        Assert.willBeEqual(
                            expression1(),
                            expression2(),
                            timeout: timeout,
                            message: message(),
                            file: file,
                            line: line
                        )
                    }
                }
            }
        }
    }

    /// Blocks the current test execution and periodically checks if the expression evaluates to `nil`. Fails if
    /// the expression result is not `nil` within the `timeout` period.
    ///
    /// - Parameters:
    ///   - expression: The expression to evaluate.
    ///   - timeout: The maximum time the function waits for the expression results to equal.
    ///   - message: The message to print when the assertion fails.
    ///
    /// - Warning: ⚠️ The expression is evaluated repeatedly during the function execution. It should not have
    ///   any side effects which can affect its result.
    static func willBeNil<T>(
        _ expression: @autoclosure () -> T?,
        timeout: TimeInterval = defaultTimeout,
        message: @autoclosure () -> String = "Failed to become `nil`",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        _ = withoutActuallyEscaping(expression) { expression in
            withoutActuallyEscaping(message) { message in

                AssertAsync {
                    Assert.willBeTrue(
                        expression() == nil,
                        timeout: timeout,
                        message: message(),
                        file: file,
                        line: line
                    )
                }
            }
        }
    }

    /// Blocks the current test execution and asynchronously checks if the provided object can be released from the memobry
    /// by assigning it to `nil`.
    ///
    /// - Warning: ⚠️ The object is destroyed during the proccess and the provided inout variable is set to `nil`, so you
    /// can't use it after this assertions has finished.
    ///
    /// - Parameters:
    ///   - object: The object to check for retain cycles.
    ///   - timeout: The maximum time the function waits for the object to be released.
    ///   - message: The message to print when the assertion fails.
    static func willBeReleased<T: AnyObject>(
        _ object: inout T!,
        timeout: TimeInterval = defaultTimeout,
        message: @autoclosure @escaping () -> String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        AssertAsync {
            Assert.willBeReleased(&object, timeout: timeout, message: message(), file: file, line: line)
        }
    }
}
