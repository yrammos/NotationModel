//
//  UnweightedGraphProtocol.swift
//  SpelledPitch
//
//  Created by James Bean on 9/22/18.
//

/// Interface for unweighted graphs.
protocol UnweightedGraphProtocol: GraphProtocol {
    var edges: Set<Edge> { get set }
    init(_ nodes: Set<Node>, _ edges: Set<Edge>)
}

extension UnweightedGraphProtocol {

    func contains(_ edge: Edge) -> Bool {
        return edges.contains(edge)
    }

    func neighbors(of source: Node, in nodes: Set<Node>? = nil) -> Set<Node> {
        return (nodes ?? self.nodes).filter { destination in
            edges.contains(Edge(source,destination))
        }
    }

    func edges(containing node: Node) -> Set<Edge> {
        return edges.filter { $0.a == node || $0.b == node }
    }

    mutating func insertEdge(from source: Node, to destination: Node) {
        insert(source)
        insert(destination)
        edges.insert(Edge(source,destination))
    }

    mutating func removeEdge(from source: Node, to destination: Node) {
        edges.remove(Edge(source,destination))
    }
}