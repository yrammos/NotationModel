//
//  OrderedPair.swift
//  PitchSpeller
//
//  Created by Benjamin Wetherfield on 6/30/18.
//

/// Pair of values for which the order matters.
struct OrderedPair <T>: SwappablePair {

    // MARK: - Instance Properties

    let a: T
    let b: T

    // MARK: - Initializers

    init(_ pair: (T, T)) {
        self.a = pair.0
        self.b = pair.1
    }
    
    init(_ a: T, _ b: T) {
        self.a = a
        self.b = b
    }
}

// MARK: - Equatable
extension OrderedPair: Equatable where T: Equatable { }

// MARK: - Hashable
extension OrderedPair: Hashable where T: Hashable { }
