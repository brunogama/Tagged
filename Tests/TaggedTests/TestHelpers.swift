//
//  TestTags.swift
//  TaggedTests
//
//  Created by Bruno da Gama Porciuncula on 09/02/25.
//

import XCTest
@testable import Tagged

// MARK: - Test Types
enum TestTags {
    enum UserID {}
    enum Email {}
    enum Price {}
    enum Temperature {}
    enum List {}
    enum Counter {}
    enum OptionalValue {}
}

extension Tagged {
    static func fixture(
        _ value: TagRawValue
    ) -> Tagged<TypeTag, TagRawValue> {
        .init(value)
    }
}

// Common Type Aliases
typealias UserID = Tagged<TestTags.UserID, Int>
typealias Email = Tagged<TestTags.Email, String>
typealias Price = Tagged<TestTags.Price, Double>
typealias Temperature = Tagged<TestTags.Temperature, Double>
typealias IntList = Tagged<TestTags.List, [Int]>
typealias Counter = Tagged<TestTags.Counter, Int>
typealias OptionalInt = Tagged<TestTags.OptionalValue, Int?>

// MARK: - Test Fixtures
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
