//
//  GraphProtocol.swift
//  SpelledPitch
//
//  Created by James Bean on 9/22/18.
//

/// Interface for graph-like tyes.
protocol GraphProtocol {

    // MARK: - Associated Types

    /// The type of nodes contained herein.
    associatedtype Node: Hashable

    /// The type of edges contained herein.
    associatedtype Edge: SymmetricPair & Hashable where Edge.A == Node

    // MARK: - Instance Properties

    /// All of the nodes contained herein.
    var nodes: Set<Node> { get set }

    // MARK: - Initializers

    /// Creates a `GraphProtocol`-conforming type value with the given set of `nodes`.
    init(_ nodes: Set<Node>)

    // MARK: - Instance Methods

    /// - Returns: A set of nodes which are connected to the given `source`, in the given set of
    /// `nodes`.
    ///
    /// If `nodes` is `nil`, all nodes contained herein are able to be included.
    func neighbors(of source: Node, in nodes: Set<Node>?) -> Set<Node>

    /// - Returns: A set of edges containing the given `node`.
    func edges(containing node: Node) -> Set<Edge>

    /// Removes the edge from the given `source` to the given `destination`.
    mutating func removeEdge(from source: Node, to destination: Node)
}

extension GraphProtocol {

    func contains(_ node: Node) -> Bool {
        return nodes.contains(node)
    }

    func breadthFirstSearch(from source: Node, to destination: Node? = nil) -> [Node] {
        var visited: [Node] = []
        var queue: Queue<Node> = []
        queue.enqueue(source)
        visited.append(source)
        while !queue.isEmpty {
            let node = queue.dequeue()
            for neighbor in neighbors(of: node, in: nil) where !visited.contains(neighbor) {
                queue.enqueue(neighbor)
                visited.append(neighbor)
                if neighbor == destination { return visited }
            }
        }
        return visited
    }

    mutating func insert(_ node: Node) {
        nodes.insert(node)
    }
}
