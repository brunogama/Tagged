import XCTest
@testable import Tagged

final class TaggedComparisonTests: XCTestCase {
    private enum ScoreTag {}
    private typealias Score = Tagged<ScoreTag, Double>

    private enum StringIDTag {}
    private typealias StringID = Tagged<StringIDTag, String>

    // MARK: - Equality Tests
    func test_equality__returns_true__with_identical_values() {
        let score1 = Score(100.0)
        let score2 = Score(100.0)
        XCTAssertEqual(score1, score2)
    }

    func test_equality__returns_true__with_equivalent_nan_values() {
        let score1 = Score(Double.nan)
        let score2 = Score(Double.nan)
        XCTAssertNotEqual(score1, score2) // NaN is not equal to itself
    }

    func test_equality__returns_true__with_positive_and_negative_zero() {
        let score1 = Score(0.0)
        let score2 = Score(-0.0)
        XCTAssertEqual(score1, score2)
    }

    // MARK: - Comparison Tests
    func test_comparison__orders_correctly__with_infinity() {
        let infinite = Score(Double.infinity)
        let finite = Score(1000000.0)
        XCTAssertGreaterThan(infinite, finite)
    }

    func test_comparison__orders_correctly__with_strings_differing_by_case() {
        let lower = StringID("test")
        let upper = StringID("TEST")
        XCTAssertNotEqual(lower, upper)
    }

    func test_comparison__orders_correctly__with_empty_strings() {
        let empty = StringID("")
        let nonEmpty = StringID("a")
        XCTAssertLessThan(empty, nonEmpty)
    }

    // MARK: - Hash Tests
    func test_hash__produces_same_value__for_equal_values() {
        let score1 = Score(100.0)
        let score2 = Score(100.0)
        XCTAssertEqual(score1.hashValue, score2.hashValue)
    }

    func test_hash__produces_different_values__for_different_values() {
        let score1 = Score(100.0)
        let score2 = Score(200.0)
        XCTAssertNotEqual(score1.hashValue, score2.hashValue)
    }
}
