import XCTest
@testable import Tagged

// MARK: - Test Types

/// Namespace for test type tags used across test cases
enum TestTags {
    /// Tag for user ID values
    enum UserID {}
    /// Tag for email values
    enum Email {}
    /// Tag for price values
    enum Price {}
    /// Tag for temperature values
    enum Temperature {}
    /// Tag for list values
    enum List {}
    /// Tag for counter values
    enum Counter {}
    /// Tag for optional values
    enum OptionalValue {}
}

extension Tagged {
    /// Creates a test fixture instance of a Tagged value
    /// - Parameter value: The raw value to wrap
    /// - Returns: A new Tagged instance with the provided value
    static func fixture(
        _ value: RawValue
    ) -> Self {
        .init(value)
    }
}

// Common Type Aliases
/// Type-safe user identifier
typealias UserID = Tagged<TestTags.UserID, Int>
/// Type-safe email address
typealias Email = Tagged<TestTags.Email, String>
/// Type-safe price value
typealias Price = Tagged<TestTags.Price, Double>
/// Type-safe temperature value
typealias Temperature = Tagged<TestTags.Temperature, Double>
/// Type-safe integer list
typealias IntList = Tagged<TestTags.List, [Int]>
/// Type-safe counter value
typealias Counter = Tagged<TestTags.Counter, Int>
/// Type-safe optional integer
typealias OptionalInt = Tagged<TestTags.OptionalValue, Int?>

// MARK: - Test Fixtures

/// Provides common test fixtures for Tagged types
enum TaggedFixtures {
    static let validUserID = UserID.fixture(42)
    static let validEmail = Email.fixture("test@example.com")
    static let validPrice = Price.fixture(99.99)
    static let validTemperature = Temperature.fixture(72.5)
    static let validList = IntList.fixture([1, 2, 3, 4, 5])
    static let validCounter = Counter.fixture(1)
    static let validOptional = OptionalInt.fixture(42)

    static let emptyEmail = Email.fixture("")
    static let zeroPrice = Price.fixture(0.0)
    static let emptyList = IntList.fixture([])
    static let nilOptional = OptionalInt.fixture(nil)

    enum Arrays {
        static let integers = Array(1...1000)
        static let doubles = Array(1...1000).map(Double.init)
        static let strings = Array(1...1000).map(String.init)
    }
}

// MARK: - Test Models
struct TestUser: Codable {
    let id: UserID
    let email: Email
    let score: Price

    static let fixture = TestUser(
        id: TaggedFixtures.validUserID,
        email: TaggedFixtures.validEmail,
        score: TaggedFixtures.validPrice
    )
}

// MARK: - Performance Test Helpers
struct PerformanceTestHelper {
    static func measure(
        iterations: Int = 1000,
        operation: () -> Void
    ) {
        for _ in 0..<iterations {
            operation()
        }
    }

    static func measureWithResult<T>(
        iterations: Int = 1000,
        operation: () -> T
    ) -> [T] {
        (0..<iterations).map { _ in operation() }
    }
}
