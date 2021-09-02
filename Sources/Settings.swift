
import Foundation

/// The default timeout value used by the `willBe___` family of assertions. Increasing this value will make assertions wait for
/// the success longer.
public var defaultTimeout: TimeInterval = 1

/// The default timeout value used by the `stays___` family of assertions. The assertion will wait this amount of time for
/// it to stay true. Change this value with caution. Longer times will increase the total runtime of the test suite.
public var defaultTimeoutForInverseExpectations: TimeInterval = 0.1

/// The amount of time between two evaluations of the expression. Increasing this value might speed up the test execution for
/// the `willBe___` assertions under certain conditions. Increasing this value also puts more work on the main queue which might
/// in the end results in slower tests overall.
public var evaluationPeriod: TimeInterval = 1 / 1_000_000
