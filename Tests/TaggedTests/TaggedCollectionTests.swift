//
//  TaggedCollectionTests.swift
//  TaggedTests
//
//  Created by Bruno da Gama Porciuncula on 09/02/25.
//

import XCTest
@testable import Tagged

/// Tests for Collection protocol conformance of Tagged types
final class TaggedCollectionTests: XCTestCase {
    // MARK: - Type Definitions

    private enum ListTag {}
    private typealias TaggedList = Tagged<ListTag, [Int]>

    private enum StringListTag {}
    private typealias TaggedStringList = Tagged<StringListTag, [String]>

    // MARK: - Basic Collection Operations

    func test_collection__accesses_elements__with_valid_index() {
        let list = TaggedList([1, 2, 3])
        XCTAssertEqual(list[1], 2)
    }

    func test_collection__accesses_elements__with_first_index() {
        let list = TaggedList([1, 2, 3])
        XCTAssertEqual(list[list.startIndex], 1)
    }

    func test_collection__accesses_elements__with_last_index() {
        let list = TaggedList([1, 2, 3])
        let lastIndex = list.index(before: list.endIndex)
        XCTAssertEqual(list[lastIndex], 3)
    }

    // MARK: - Empty Collection Tests

    func test_collection__provides_correct_indices__when_empty() {
        let emptyList = TaggedList([])
        XCTAssertEqual(emptyList.startIndex, emptyList.endIndex)
    }

    func test_collection__has_zero_count__when_empty() {
        let emptyList = TaggedList([])
        XCTAssertEqual(emptyList.count, 0)
    }

    // MARK: - Iteration Tests

    func test_collection__iterates_all_elements__in_correct_order() {
        let list = TaggedList([1, 2, 3])
        var iteration = 1

        for element in list {
            XCTAssertEqual(element, iteration)
            iteration += 1
        }
    }

    // MARK: - Bidirectional Collection Tests

    // swiftlint:disable:next function_body_length
    func test_collection__iterates_backward__from_end_to_start() {
        let list = TaggedList([1, 2, 3])
        var iteration = 3
        var index = list.index(before: list.endIndex)

        while index >= list.startIndex {
            XCTAssertEqual(list[index], iteration)
            iteration -= 1
            if index > list.startIndex {
                index = list.index(before: index)
            } else {
                break
            }
        }
    }

    // MARK: - Unicode Support Tests

    func test_collection__handles_strings__with_unicode_scalars() {
        let list = TaggedStringList(["Hello", "🌍", "世界"])
        XCTAssertEqual(list.count, 3)
        XCTAssertEqual(list[1], "🌍")
    }
}
