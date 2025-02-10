import XCTest
@testable import Tagged

/// Tests for numeric operations on Tagged types
/// - Note: This test suite verifies both floating-point and integer arithmetic
// swiftlint:disable:next type_body_length cyclomatic_complexity
final class TaggedNumericTests<IntegerType: FixedWidthInteger>: XCTestCase {
    // MARK: - Type Definitions

    private enum PriceTag {}
    private typealias Price = Tagged<PriceTag, Double>

    private enum QuantityTag {}
    private typealias Quantity = Tagged<QuantityTag, IntegerType>

    // MARK: - Addition Tests

    func test_addition__adds_values__with_positive_numbers() {
        let price1 = Price(10.0)
        let price2 = Price(20.0)
        XCTAssertEqual(price1 + price2, Price(30.0))
    }

    func test_addition__adds_values__with_negative_numbers() {
        let price1 = Price(-10.0)
        let price2 = Price(20.0)
        XCTAssertEqual(price1 + price2, Price(10.0))
    }

    func test_addition__adds_values__with_zero() {
        let price1 = Price(10.0)
        let price2 = Price(0.0)
        XCTAssertEqual(price1 + price2, Price(10.0))
    }

    // MARK: - Multiplication Tests

    func test_multiplication__multiplies_value__with_positive_scalar() {
        let price = Price(10.0)
        XCTAssertEqual(price * 2.0, Price(20.0))
    }

    func test_multiplication__multiplies_value__with_negative_scalar() {
        let price = Price(10.0)
        XCTAssertEqual(price * -2.0, Price(-20.0))
    }

    func test_multiplication__multiplies_value__with_zero() {
        let price = Price(10.0)
        XCTAssertEqual(price * 0.0, Price(0.0))
    }

    // MARK: - Division Tests

    func test_division__divides_value__with_positive_divisor() {
        let price = Price(10.0)
        XCTAssertEqual(price / 2.0, Price(5.0))
    }

    func test_division__produces_infinity__when_dividing_by_zero() {
        let price = Price(10.0)
        let result = price / 0.0
        XCTAssertTrue(result.rawValue.isInfinite)
    }

    // MARK: - Integer Arithmetic Tests

    func test_integer_arithmetic__handles_overflow__when_exceeding_max_value() {
        let quantity = Quantity(IntegerType.max)
        let result = quantity + Quantity(1)
        XCTAssertLessThan(result.rawValue, quantity.rawValue)
    }

    func test_integer_arithmetic__handles_underflow__when_exceeding_min_value() {
        let quantity = Quantity(IntegerType.min)
        let result = quantity - Quantity(1)
        XCTAssertGreaterThan(result.rawValue, quantity.rawValue)
    }
}
