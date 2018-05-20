//
//  NamedOrderedInterval.swift
//  SpelledPitch
//
//  Created by James Bean on 1/8/17.
//
//

import DataStructures

/// Named intervals between two `SpelledPitch` values that honors order between them.
public struct NamedOrderedInterval {

    // MARK: - Associated Types

    /// Type describing the quality of a `NamedInterval`-conforming type.
    public typealias Quality = NamedIntervalQuality

    // MARK: - Nested Types

    /// Direction of a `NamedOrderedInterval`.
    public enum Direction: InvertibleEnum {
        case ascending, descending
    }

    /// Ordinal for `NamedOrderedInterval`.
    public enum Ordinal: Invertible {

        /// Perfect `Ordinal` cases.
        public enum Perfect: InvertibleEnum {
            case unison, fourth, fifth

            /// Customizes the `InvertibleEnum` `inverse` implementation to return `unison` as the
            /// inverse of `unison`.
            ///
            /// - Returns: Inverse of `self`.
            public var inverse: Perfect {
                let index = Perfect.allCases.index(of: self)!
                guard index > 0 else { return self }
                let inverseIndex = Perfect.allCases.count - index
                return Perfect.allCases[inverseIndex]
            }
        }

        /// Imperfect `Ordinal` cases
        public enum Imperfect: InvertibleEnum {
            case second, third, sixth, seventh
        }

        case perfect(Perfect)
        case imperfect(Imperfect)

        /// - Returns: Inversion of `self`.
        ///
        ///     let third: Ordinal = .imperfect(.third)
        ///     third.inverse // => .imperfect(.sixth)
        ///     let fifth: Ordinal = .perfect(.fifth)
        ///     fifth.inverse // => .perfect(.fourth)
        ///
        public var inverse: NamedOrderedInterval.Ordinal {
            switch self {
            case .perfect(let ordinal):
                return .perfect(ordinal.inverse)
            case .imperfect(let ordinal):
                return .imperfect(ordinal.inverse)
            }
        }
    }

    // MARK: - Type Properties

    /// Unison interval.
    public static var unison: NamedOrderedInterval {
        return .init(.perfect, .unison)
    }

    // MARK: - Instance Properties

    /// The direction of a `NamedOrderedInterval`.
    public let direction: Direction

    /// Ordinal value of a `NamedOrderedInterval`
    /// (`unison`, `second`, `third`, `fourth`, `fifth`, `sixth`, `seventh`).
    public let ordinal: Ordinal

    /// /// Quality value of a `NamedUnorderedInterval`
    /// (`diminished`, `minor`, `perfect`, `major`, `augmented`).
    public let quality: Quality

    // MARK: - Initializers

    /// Create an `NamedOrderedInterval` with a given `quality` and `ordinal`.
    internal init(_ direction: Direction = .ascending, _ quality: Quality, _ ordinal: Ordinal) {
        self.direction = direction
        self.quality = quality
        self.ordinal = ordinal
    }

    /// Create a `NamedInterval` with two `SpelledPitch` values.
    ///
    /// - TODO: Implement!
    internal init(_ a: SpelledPitch, _ b: SpelledPitch) {
        fatalError()
    }

    /// Create a perfect `NamedOrderedInterval`.
    ///
    ///     let perfectFifth = NamedOrderedInterval(.perfect, .fifth)
    ///
    public init(_ quality: Quality.Perfect, _ ordinal: Ordinal.Perfect) {
        self.direction = .ascending
        self.quality = .perfect(.perfect)
        self.ordinal = .perfect(ordinal)
    }

    /// Create a perfect `NamedOrderedInterval` with a given `direction`.
    ///
    ///     let descendingPerfectFifth = NamedOrderedInterval(.descending, .perfect, .fifth)
    ///
    public init(_ direction: Direction, _ quality: Quality.Perfect, _ ordinal: Ordinal.Perfect) {
        self.direction = direction
        self.quality = .perfect(.perfect)
        self.ordinal = .perfect(ordinal)
    }

    /// Create an imperfect `NamedOrderedInterval`.
    ///
    ///     let majorSecond = NamedOrderedInterval(.major, .second)
    ///     let minorThird = NamedOrderedInterval(.minor, .third)
    ///     let majorSixth = NamedOrderedInterval(.major, .sixth)
    ///     let minorSeventh = NamedOrderedInterval(.minor, .seventh)
    ///
    public init(_ quality: Quality.Imperfect, _ ordinal: Ordinal.Imperfect) {
        self.direction = .ascending
        self.quality = .imperfect(quality)
        self.ordinal = .imperfect(ordinal)
    }

    /// Create an imperfect `NamedOrderedInterval`.
    ///
    ///     let majorSecond = NamedOrderedInterval(.ascending, .major, .second)
    ///     let minorThird = NamedOrderedInterval(.descending, .minor, .third)
    ///     let majorSixth = NamedOrderedInterval(.ascending, .major, .sixth)
    ///     let minorSeventh = NamedOrderedInterval(.descending, .minor, .seventh)
    ///
    public init(
        _ direction: Direction,
        _ quality: Quality.Imperfect,
        _ ordinal: Ordinal.Imperfect
    )
    {
        self.direction = direction
        self.quality = .imperfect(quality)
        self.ordinal = .imperfect(ordinal)
    }

    /// Create an augmented or diminished `NamedOrderedInterval` with an imperfect ordinal. These
    /// intervals can be up to quintuple augmented or diminished.
    ///
    ///     let doubleDiminishedSecond = NamedOrderedInterval(.double, .diminished, .second)
    ///     let tripleAugmentedThird = NamedOrderedInterval(.triple, .augmented, .third)
    ///
    public init(
        _ degree: Quality.Extended.Degree,
        _ quality: Quality.Extended.AugmentedOrDiminished,
        _ ordinal: Ordinal.Imperfect
    )
    {
        self.direction = .ascending
        self.quality = .augmentedOrDiminished(.init(degree, quality))
        self.ordinal = .imperfect(ordinal)
    }

    /// Create an augmented or diminished `NamedOrderedInterval` with a given `direction` and an
    /// imperfect ordinal. These intervals can be up to quintuple augmented or diminished.
    ///
    ///     let doubleDiminishedSecond = NamedOrderedInterval(.descending, .double, .diminished, .second)
    ///     let tripleAugmentedThird = NamedOrderedInterval(.ascending, .triple, .augmented, .third)
    ///
    public init(
        _ direction: Direction,
        _ degree: Quality.Extended.Degree,
        _ quality: Quality.Extended.AugmentedOrDiminished,
        _ ordinal: Ordinal.Imperfect
    )
    {
        self.direction = direction
        self.quality = .augmentedOrDiminished(.init(degree, quality))
        self.ordinal = .imperfect(ordinal)
    }

    /// Create an augmented or diminished `NamedOrderedInterval` with a perfect ordinal. These
    /// intervals can be up to quintuple augmented or diminished.
    ///
    ///     let doubleAugmentedUnison = NamedOrderedInterval(.double, .augmented, .unison)
    ///     let tripleDiminishedFourth = NamedOrderedInterval(.triple, .diminished, .fourth)
    ///
    public init(
        _ degree: Quality.Extended.Degree,
        _ quality: Quality.Extended.AugmentedOrDiminished,
        _ ordinal: Ordinal.Perfect
    )
    {
        self.direction = .ascending
        self.quality = .augmentedOrDiminished(.init(degree, quality))
        self.ordinal = .perfect(ordinal)
    }

    /// Create an augmented or diminished `NamedOrderedInterval` with a given `direction` and a
    /// perfect ordinal. These intervals can be up to quintuple augmented or diminished.
    ///
    ///     let doubleAugmentedUnison = NamedOrderedInterval(.descending, .double, .augmented, .unison)
    ///     let tripleDiminishedFourth = NamedOrderedInterval(.ascending, .triple, .diminished, .fourth)
    ///
    public init(
        _ direction: Direction,
        _ degree: Quality.Extended.Degree,
        _ quality: Quality.Extended.AugmentedOrDiminished,
        _ ordinal: Ordinal.Perfect
    )
    {
        self.direction = direction
        self.quality = .augmentedOrDiminished(.init(degree, quality))
        self.ordinal = .perfect(ordinal)
    }

    /// Create an augmented or diminished `NamedOrderedInterval` with an imperfect ordinal.
    ///
    ///     let diminishedSecond = NamedOrderedInterval(.diminished, .second)
    ///     let augmentedSixth = NamedOrderedInterval(.augmented, .sixth)
    ///
    public init(
        _ quality: Quality.Extended.AugmentedOrDiminished,
        _ ordinal: Ordinal.Imperfect
    )
    {
        self.direction = .ascending
        self.quality = .augmentedOrDiminished(.init(.single, quality))
        self.ordinal = .imperfect(ordinal)
    }

    /// Create an augmented or diminished `NamedOrderedInterval` with a given `direction` and an
    /// imperfect ordinal.
    ///
    ///     let diminishedSecond = NamedOrderedInterval(.descending, .diminished, .second)
    ///     let augmentedSixth = NamedOrderedInterval(.ascending, .augmented, .sixth)
    ///
    public init(
        _ direction: Direction,
        _ quality: Quality.Extended.AugmentedOrDiminished,
        _ ordinal: Ordinal.Imperfect
    )
    {
        self.direction = direction
        self.quality = .augmentedOrDiminished(.init(.single, quality))
        self.ordinal = .imperfect(ordinal)
    }

    /// Create an augmented or diminished `NamedOrderedInterval` with a perfect ordinal.
    ///
    ///     let augmentedUnison = NamedOrderedInterval(.augmented, .unison)
    ///     let diminishedFourth = NamedOrderedInterval(.diminished, .fourth)
    ///
    public init(
        _ quality: Quality.Extended.AugmentedOrDiminished,
        _ ordinal: Ordinal.Perfect
    )
    {
        self.direction = .ascending
        self.quality = .augmentedOrDiminished(.init(.single, quality))
        self.ordinal = .perfect(ordinal)
    }

    /// Create an augmented or diminished `NamedOrderedInterval` with a given `direction` and a
    /// perfect ordinal.
    ///
    ///     let augmentedUnison = NamedOrderedInterval(.ascending, .augmented, .unison)
    ///     let diminishedFourth = NamedOrderedInterval(.descending, .diminished, .fourth)
    ///
    public init(
        _ direction: Direction,
        _ quality: Quality.Extended.AugmentedOrDiminished,
        _ ordinal: Ordinal.Perfect
    )
    {
        self.direction = direction
        self.quality = .augmentedOrDiminished(.init(.single, quality))
        self.ordinal = .perfect(ordinal)
    }
}

extension NamedOrderedInterval.Ordinal: Equatable, Hashable { }
extension NamedOrderedInterval: Equatable, Hashable { }

extension NamedOrderedInterval: Invertible {

    /// - Returns: Inversion of `self`.
    public var inverse: NamedOrderedInterval {
        return .init(direction.inverse, quality.inverse, ordinal.inverse)
    }
}