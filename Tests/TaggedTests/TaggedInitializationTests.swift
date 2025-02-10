//
//  TaggedInitializationTests.swift
//  TaggedTests
//
//  Created by Bruno da Gama Porciuncula on 09/02/25.
//

import XCTest
@testable import Tagged

final class TaggedInitializationTests: XCTestCase {
    // MARK: - Test Types
    private enum UserIDTag {}
    private typealias UserID = Tagged<UserIDTag, Int>

    private enum EmailTag {}
    private typealias Email = Tagged<EmailTag, String>

    private enum OptionalTag {}
    private typealias OptionalValue = Tagged<OptionalTag, Int?>

    private enum OptionalIntTag {}
    private typealias OptionalInt = Tagged<OptionalIntTag, Optional<Int>>

    // MARK: - Basic Initialization
    func test_initialization__creates_tagged_value__with_valid_input() {
        let userID = UserID(42)
        XCTAssertEqual(userID.rawValue, 42)
    }

    func test_initialization__creates_tagged_value__with_zero() {
        let userID = UserID(0)
        XCTAssertEqual(userID.rawValue, 0)
    }

    func test_initialization__creates_tagged_value__with_negative_number() {
        let userID = UserID(-42)
        XCTAssertEqual(userID.rawValue, -42)
    }

    // MARK: - String Initialization
    func test_initialization__creates_tagged_value__with_empty_string() {
        let email = Email("")
        XCTAssertEqual(email.rawValue, "")
    }

    func test_initialization__creates_tagged_value__with_unicode_string() {
        let email = Email("test📧@example.com")
        XCTAssertEqual(email.rawValue, "test📧@example.com")
    }

    // MARK: - Optional Initialization
    func test_initialization__creates_tagged_value__with_optional_wrapped_value() {
        let optional = OptionalInt(wrapped: 42)
        XCTAssertEqual(optional.wrapped, 42)
    }

    func test_initialization__creates_tagged_value__with_nil() {
        let optional: OptionalInt = nil
        XCTAssertNil(optional.wrapped)
    }

    func test_initialization__creates_tagged_value__with_explicit_nil() {
        let optional = OptionalInt(nilLiteral: ())
        XCTAssertNil(optional.wrapped)
    }

    func test_optional__unwraps_value__when_present() {
        let optional = OptionalInt(wrapped: 42)
        if let value = optional.wrapped {
            XCTAssertEqual(value, 42)
        } else {
            XCTFail("Value should be present")
        }
    }

    func test_optional__returns_nil__when_empty() {
        let optional: OptionalInt = nil
        XCTAssertNil(optional.wrapped)
    }

    // MARK: - RawRepresentable
    func test_rawRepresentable__initializes__with_raw_value() {
        let userID = UserID(rawValue: 42)
        XCTAssertEqual(userID.rawValue, 42)
    }
}
