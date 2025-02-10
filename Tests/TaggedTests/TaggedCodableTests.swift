//
//  TaggedCodableTests.swift
//  TaggedTests
//
//  Created by Bruno da Gama Porciuncula on 09/02/25.
//

import XCTest
@testable import Tagged

final class TaggedCodableTests: XCTestCase {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Single Value Tests
    func test_encoding__produces_valid_json__for_primitive_types() throws {
        // Integer
        let encodedUserID = try encoder.encode(TaggedFixtures.validUserID)
        XCTAssertEqual(String(data: encodedUserID, encoding: .utf8), "42")

        // String
        let encodedEmail = try encoder.encode(TaggedFixtures.validEmail)
        XCTAssertEqual(String(data: encodedEmail, encoding: .utf8), "\"test@example.com\"")

        // Double
        let encodedPrice = try encoder.encode(TaggedFixtures.validPrice)
        XCTAssertEqual(String(data: encodedPrice, encoding: .utf8), "99.99")
    }

    func test_decoding__creates_tagged_value__from_valid_json() throws {
        // Integer
        let userIDData = "42".data(using: .utf8)!
        let decodedUserID = try decoder.decode(UserID.self, from: userIDData)
        XCTAssertEqual(decodedUserID, TaggedFixtures.validUserID)

        // String
        let emailData = "\"test@example.com\"".data(using: .utf8)!
        let decodedEmail = try decoder.decode(Email.self, from: emailData)
        XCTAssertEqual(decodedEmail, TaggedFixtures.validEmail)
    }

    func test_codable__maintains_value__through_coding_cycle() throws {
        let original = TestUser.fixture
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(TestUser.self, from: encoded)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.email, original.email)
        XCTAssertEqual(decoded.score, original.score)
    }

    // MARK: - Edge Cases
    func test_decoding__fails__with_invalid_json() {
        let invalidData = "invalid".data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(UserID.self, from: invalidData)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func test_decoding__handles__empty_string() throws {
        let emptyStringData = "\"\"".data(using: .utf8)!
        let decoded = try decoder.decode(Email.self, from: emptyStringData)
        XCTAssertEqual(decoded, TaggedFixtures.emptyEmail)
    }

    func test_codable__handles__optional_values() throws {
        let nilOptional = TaggedFixtures.nilOptional
        let encoded = try encoder.encode(nilOptional)
        let decoded = try decoder.decode(OptionalInt.self, from: encoded)
        XCTAssertEqual(decoded, nilOptional)
    }

    func test_codable__handles__array_of_tagged_values() throws {
        let array = [TaggedFixtures.validUserID, UserID(43), UserID(44)]
        let encoded = try encoder.encode(array)
        let decoded = try decoder.decode([UserID].self, from: encoded)
        XCTAssertEqual(decoded, array)
    }
}
