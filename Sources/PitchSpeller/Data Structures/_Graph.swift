//
//  _Graph.swift
//  PitchSpeller
//
//  Created by Benjamin Wetherfield on 7/14/18.
//

// MARK: - Directedness Flags

protocol Directedness { }
protocol Directed: Directedness { }
protocol Undirected: Directedness { }

enum WithDirectedEdges: Directed { }
enum WithUndirectedEdges: Undirected { }

// MARK: - Weightedness Flags

protocol Weightedness { }
protocol Unweighted: Weightedness { }
protocol AsWeight: Weightedness { }

extension Double: AsWeight { }
enum WithoutWeights: Unweighted { }

struct _Graph<Weight: Weightedness, DirectednessFlag: Directedness> {
    
}

extension _Graph where Weight: Numeric, DirectednessFlag: Directed {
    
}
