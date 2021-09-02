
import XCTest

public extension Assert {
    /// Periodically checks that the expression evaluates stays `FALSE` for the whole `timeout` period.. Fails if the expression
    /// becomes `TRUE` before the end of the `timeout` period.
    ///
    /// - Parameters:
    ///   - expression: The expression to evaluate.
    ///   - timeout: The maximum time the function waits for the expression results to equal.
    ///   - message: The message to print when the assertion fails.
    ///
    /// - Warning: ⚠️ The expression is evaluated repeatedly during the function execution. It should not have
    ///   any side effects which can affect its result.
    static func staysFalse(
        _ expression: @autoclosure @escaping () -> Bool,
        timeout: TimeInterval = defaultTimeoutForInverseExpectations,
        message: @autoclosure @escaping () -> String = "Failed to stay `FALSE`",
        file: StaticString = #file,
        line: UInt = #line
    ) -> Assertion {
        staysTrue(!expression(), timeout: timeout, message: message(), file: file, line: line)
    }

    /// Periodically checks that the expression evaluates stays `TRUE` for the whole `timeout` period.. Fails if the expression
    /// becomes `FALSE` before the end of the `timeout` period.
    ///
    /// - Parameters:
    ///   - expression: The expression to evaluate.
    ///   - timeout: The maximum time the function waits for the expression results to equal.
    ///   - message: The message to print when the assertion fails.
    ///
    /// - Warning: ⚠️ The expression is evaluated repeatedly during the function execution. It should not have
    ///   any side effects which can affect its result.
    static func staysTrue(
        _ expression: @autoclosure @escaping () -> Bool,
        timeout: TimeInterval = defaultTimeoutForInverseExpectations,
        message: @autoclosure @escaping () -> String = "Failed to stay `TRUE`",
        file: StaticString = #file,
        line: UInt = #line
    ) -> Assertion {
        Assertion { elapsedTime in
            if elapsedTime >= timeout {
                // Success
                return .idle

            } else if expression() == false {
                // Failure
                XCTFail(message(), file: file, line: line)
                return .idle
            }

            return .active
        }
    }

    /// Blocks the current test execution and periodically checks for the equality of the provided expressions for
    /// the whole `timeout` period. Fails if the expression results are not equal before the end of the `timeout` period.
    ///
    /// - Parameters:
    ///   - expression1: The first expression to evaluate.
    ///   - expression2: The first expression to evaluate.
    ///   - timeout: The maximum time the function waits for the expression results to equal.
    ///   - message: The message to print when the assertion fails.
    ///
    /// - Warning: ⚠️ Both expressions are evaluated repeatedly during the function execution. The expressions should not have
    ///   any side effects which can affect their results.
    static func staysEqual<T: Equatable>(
        _ expression1: @autoclosure @escaping () -> T,
        _ expression2: @autoclosure @escaping () -> T,
        timeout: TimeInterval = defaultTimeoutForInverseExpectations,
        message: @autoclosure @escaping () -> String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Assertion {
        // We can't use this as the default parameter because of the string interpolation.
        var defaultMessage: String {
            "\"\(String(describing: expression1()))\" failed to stay equal to \"\(String(describing: expression2()))\""
        }

        return staysTrue(
            expression1() == expression2(),
            timeout: timeout,
            message: message() ?? defaultMessage,
            file: file,
            line: line
        )
    }
}

public extension AssertAsync {

    /// Blocks the current test execution and periodically checks that the expression evaluates stays `TRUE` for
    /// the whole `timeout` period. Fails if the expression becommes `FALSE` before the end of the `timeout` period.
    ///
    /// - Parameters:
    ///   - expression: The expression to evaluate.
    ///   - timeout: The maximum time the function waits for the expression results to equal.
    ///   - message: The message to print when the assertion fails.
    ///
    /// - Warning: ⚠️ The expression is evaluated repeatedly during the function execution. It should not have
    ///   any side effects which can affect its result.
    static func staysTrue(
        _ expression: @autoclosure () -> Bool,
        timeout: TimeInterval = defaultTimeoutForInverseExpectations,
        message: @autoclosure () -> String = "Failed to stay `TRUE`",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        _ = withoutActuallyEscaping(expression) { expression in
            withoutActuallyEscaping(message) { message in
                AssertAsync {
                    Assert.staysTrue(expression(), timeout: timeout, message: message(), file: file, line: line)
                }
            }
        }
    }

    /// Blocks the current test execution and periodically checks that the expression evaluates stays `TRUE` for
    /// the whole `timeout` period. Fails if the expression becomes `FALSE` before the end of the `timeout` period.
    ///
    /// - Parameters:
    ///   - expression: The expression to evaluate.
    ///   - timeout: The maximum time the function waits for the expression results to equal.
    ///   - message: The message to print when the assertion fails.
    ///
    /// - Warning: ⚠️ The expression is evaluated repeatedly during the function execution. It should not have
    ///   any side effects which can affect its result.
    static func staysFalse(
        _ expression: @autoclosure () -> Bool,
        timeout: TimeInterval = defaultTimeoutForInverseExpectations,
        message: @autoclosure () -> String = "Failed to stay `FALSE`",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        _ = withoutActuallyEscaping(expression) { expression in
            withoutActuallyEscaping(message) { message in
                AssertAsync {
                    Assert.staysFalse(expression(), timeout: timeout, message: message(), file: file, line: line)
                }
            }
        }
    }

    /// Blocks the current test execution and periodically checks for the equality of the provided expressions for
    /// the whole `timeout` period. Fails if the expression results are not equal before the end of the `timeout` period.
    ///
    /// - Parameters:
    ///   - expression1: The first expression to evaluate.
    ///   - expression2: The first expression to evaluate.
    ///   - timeout: The maximum time the function waits for the expression results to equal.
    ///   - message: The message to print when the assertion fails.
    ///
    /// - Warning: ⚠️ Both expressions are evaluated repeatedly during the function execution. The expressions should not have
    ///   any side effects which can affect their results.
    static func staysEqual<T: Equatable>(
        _ expression1: @autoclosure () -> T,
        _ expression2: @autoclosure () -> T,
        timeout: TimeInterval = defaultTimeoutForInverseExpectations,
        message: @autoclosure () -> String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        _ = withoutActuallyEscaping(expression1) { expression1 in
            withoutActuallyEscaping(expression2) { expression2 in
                withoutActuallyEscaping(message) { message in

                    AssertAsync {
                        Assert.staysEqual(
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
}
