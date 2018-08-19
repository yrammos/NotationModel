//
//  TuningSystem.swift
//  SpelledPitch
//
//  Createsd by James Bean on 8/18/18.
//

/// Interface for types which implement a tuning system.
public protocol TuningSystem {

    // MARK: - Associated Types

    /// The type which is the model layer of an `Accidental`.
    associatedtype Modifier: PitchSpellingModifier
}

/// Interface for types which modify a `LetterName` value.
public protocol PitchSpellingModifier: Comparable, Hashable, CustomStringConvertible {

    // MARK: - Instance Properties

    /// The amount that a `PitchSpellingModifier` modifies the base `Pitch.Class` of a `LetterName`
    /// (in percentage of a `NoteNumber`).
    var adjustment: Double { get }
}

extension PitchSpellingModifier {

    // MARK: - Equatable

    /// - Returns: `true` if the `adjustment` property of the `lhs` value is equal to the
    /// `adjustment` property of the `rhs` value. Otherwise `false`.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.adjustment == rhs.adjustment
    }
}

extension PitchSpellingModifier {

    // MARK: - Hashable

    /// - Returns: The `hashValue` of the `adjustment` property.
    public var hashValue: Int {
        return adjustment.hashValue
    }
}


extension PitchSpellingModifier {

    // MARK: - Comparable

    /// - Returns: `true` if the `adjustment` property of the `lhs` value is less than the
    /// `adjustment` property of the `rhs` value. Otherwise `false`.
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.adjustment < rhs.adjustment
    }
}
