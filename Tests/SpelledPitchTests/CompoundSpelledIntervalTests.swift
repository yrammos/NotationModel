//
//  CompoundSpelledIntervalTests.swift
//  SpelledPitch
//
//  Created by James Bean on 8/17/18.
//

import XCTest
import Pitch
import SpelledPitch

class CompoundSpelledIntervalTests: XCTestCase {

    func testInitTwoSpelledPitchesUnison() {
        let a = SpelledPitch<EDO12>.middleC
        let b = SpelledPitch<EDO12>.middleC
        let interval = CompoundSpelledInterval(a,b)
        let expected = CompoundSpelledInterval(.unison)
        XCTAssertEqual(interval, expected)
    }

    func testInitTwoSpelledPitchesAscendingMinorSecond() {
        let a = SpelledPitch<EDO12>(Pitch.Spelling(.f))
        let b = SpelledPitch<EDO12>(Pitch.Spelling(.f, .sharp(1)))
        let interval = CompoundSpelledInterval(a,b)
        let expected = CompoundSpelledInterval(.init(.augmented, .unison))
        XCTAssertEqual(interval, expected)
    }

    func testInitTwoSpelledPitchesDescendingMajorSecond() {
        let a = SpelledPitch<EDO12>(Pitch.Spelling(.g))
        let b = SpelledPitch<EDO12>(Pitch.Spelling(.f))
        let interval = CompoundSpelledInterval(a,b)
        let expected = CompoundSpelledInterval(.init(.descending, .major, .second))
        XCTAssertEqual(interval, expected)
    }

    func testInitTwoSpelledPitchesAscendingMinorSixth() {
        let a = SpelledPitch<EDO12>(Pitch.Spelling(.d))
        let b = SpelledPitch<EDO12>(Pitch.Spelling(.b, .flat(1)))
        let interval = CompoundSpelledInterval(a,b)
        let expected = CompoundSpelledInterval(.init(.ascending, .minor, .sixth))
        XCTAssertEqual(interval, expected)
    }

    func testInitTwoSpelledPitchesAscendingMajorTenth() {
        let a = SpelledPitch<EDO12>(Pitch.Spelling(.d), 4)
        let b = SpelledPitch<EDO12>(Pitch.Spelling(.f, .sharp(1)), 5)
        let interval = CompoundSpelledInterval(a,b)
        let expected = CompoundSpelledInterval(.init(.major, .third), displacedBy: 1)
        XCTAssertEqual(interval, expected)
    }

    func testInitTwoSpelledPitchesDescendingPerfectEleventh() {
        let a = SpelledPitch<EDO12>(Pitch.Spelling(.e), 4)
        let b = SpelledPitch<EDO12>(Pitch.Spelling(.b), 3)
        let interval = CompoundSpelledInterval(a,b)
        let expected = CompoundSpelledInterval(.init(.descending, .perfect, .fourth), displacedBy: 1)
        XCTAssertEqual(interval, expected)
    }
}