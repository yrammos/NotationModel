//
//  FlowNetwork.swift
//  PitchSpeller
//
//  Created by James Bean on 5/24/18.
//

import DataStructures
import Algebra

extension Double: AdditiveGroup {
    public var inverse: Double {
        return -self
    }
}

/// Directed graph with several properties:
/// - Each edge has a capacity for flow
/// - A "source" node, which only emanates flow outward
/// - A "sink" node, which only receives flow
public struct FlowNetwork<Node: Hashable, Weight: AdditiveGroup & Comparable>:
    WeightedGraphProtocol,
    DirectedGraphProtocol
{
    public var weights: [Edge: Weight]
    public var nodes: Set<Node>
    public var source: Node
    public var sink: Node
}

extension FlowNetwork {
    
    public typealias Edge = OrderedPair<Node>
}

extension FlowNetwork {

    // MARK: - Initializers

    /// Creates a `FlowNetwork` with the given `directedGraph` and the given `source` and `sink`
    /// nodes.
    init(_ directedGraph: WeightedDirectedGraph<Node,Weight>, source: Node, sink: Node) {
        self.nodes = directedGraph.nodes
        self.weights = directedGraph.weights
        self.source = source
        self.sink = sink
    }

    /// Creates a `FlowNetwork` with the given `source`, `sink`, `nodes`, and `weights`.
    public init(source: Node, sink: Node, nodes: Set<Node> = [], weights: [Edge: Weight] = [:]) {
        self.source = source
        self.sink = sink
        self.nodes = nodes
        self.weights = weights
    }
}

extension FlowNetwork {
    
    mutating func mask <Scheme: UnweightedGraphSchemeProtocol> (_ adjacencyScheme: Scheme) where
        Scheme.Node == Node
    {
        for edge in edges where !adjacencyScheme.containsEdge(from: edge.a, to: edge.b) {
            remove(edge)
        }
    }
}

extension FlowNetwork where Weight: Numeric {
    mutating func mask <Scheme: WeightedGraphSchemeProtocol> (_ weightScheme: Scheme) where
        Scheme.Node == Node,
        Scheme.Weight == Weight
    {
        for edge in edges {
            if let scalar = weightScheme.weight(from: edge.a, to: edge.b) {
                updateEdge(edge) { $0 * scalar }
            } else {
                remove(edge)
            }
        }
    }
}

extension FlowNetwork {

    // MARK: - Instance Methods

    func contains(_ node: Node) -> Bool {
        return node == source || node == sink || nodes.contains(node)
    }
}

extension FlowNetwork {

    // MARK: - Mutating Methods

    mutating func reduceFlow(through edge: Edge, by amount: Weight) {
        updateEdge(edge) { weight in weight - amount }
    }

    /// Removes the given edge if its weight is `0`. This happens after an edge, which has the
    /// minimum flow of an augmenting path, is reduced by the minimum flow (which is its previous
    /// value).
    mutating func removeEdgeIfFlowless (_ edge: Edge) {
        if weight(edge) == .zero {
            remove(edge)
        }
    }

    /// Inserts an edge in the opposite direction of the given `edge` with the minimum flow
    mutating func updateBackEdge(_ edge: Edge, by minimumFlow: Weight) {
        let reversedEdge = edge.swapped
        if contains(reversedEdge) {
            updateEdge(reversedEdge) { capacity in capacity + minimumFlow }
        } else {
            insertEdge(reversedEdge, weight: minimumFlow)
        }
    }

    /// Reduces the flow of the given `edge` by the given `minimumFlow`. If the new flow through
    /// the `edge` is now `0`, removes the `edge` from the network. Updates the reverse of the given
    /// `edge` by the given `minimumFlow`.
    mutating func pushFlow(through edge: Edge, by minimumFlow: Weight) {
        reduceFlow(through: edge, by: minimumFlow)
        removeEdgeIfFlowless(edge)
        updateBackEdge(edge, by: minimumFlow)
    }

    /// Pushes flow through the given `path` in this `graph`.
    mutating func pushFlow(through path: [Node]) {
        let edges = path.pairs.map(OrderedPair.init)
        let minimumFlow = edges.compactMap(weight).min() ?? .zero
        edges.forEach { edge in pushFlow(through: edge, by: minimumFlow) }
    }
}

extension FlowNetwork {

    // MARK: - Computed Properties

    /// - Returns: All of the `Node` values contained herein which are neither the `source` nor
    /// the `sink`.
    public var internalNodes: [Node] {
        return nodes.filter { $0 != source && $0 != sink }
    }

    /// - Returns: A minimum cut with nodes included on the `sink` side in case of a
    /// tiebreak (in- and out- edges saturated).
    public var minimumCut: (Set<Node>, Set<Node>) {
        let (_, residualNetwork) = maximumFlowAndResidualNetwork
        let sourceSideNodes = Set(residualNetwork.breadthFirstSearch(from: source))
        let notSourceSideNodes = residualNetwork.nodes.subtracting(sourceSideNodes)
        return (sourceSideNodes, notSourceSideNodes)
    }

    /// - Returns: (0) The maximum flow of the network and (1) the residual network produced after
    /// pushing all possible flow from source to sink (while satisfying flow constraints) - with
    /// saturated edges flipped and all weights removed.
    var maximumFlowAndResidualNetwork: (flow: Weight, network: FlowNetwork<Node, Weight>) {
        // Make a copy of the directed representation of the network to be mutated by pushing flow
        // through it.
        var residualNetwork = self
        // While an augmenting path (a path emanating directionally from the source node) can be
        // found, push flow through the path, mutating the residual network
        while let augmentingPath = residualNetwork.shortestUnweightedPath(from: source, to: sink) {
            residualNetwork.pushFlow(through: augmentingPath)
        }
        // Compares the edges in the mutated residual network against the original directed
        // graph.
        let flow: Weight = {
            let sourceEdges = neighbors(of: source).lazy
                .map { OrderedPair(self.source, $0) }
                .partition(residualNetwork.contains)
            let edgesPresent = sourceEdges.whereTrue.lazy
                .map { edge in self.weight(edge)! - residualNetwork.weight(edge)! }
                .reduce(.zero,+)
            let edgesAbsent = sourceEdges.whereFalse.lazy
                .compactMap(weight)
                .reduce(.zero,+)
            return edgesPresent + edgesAbsent
        }()
        return (flow: flow, network: residualNetwork)
    }
}

extension Sequence {

    func filterComplement (_ predicate: (Element) -> Bool) -> [Element] {
        return filter { !predicate($0) }
    }

    func partition (_ predicate: (Element) -> Bool) -> (whereFalse: [Element], whereTrue: [Element]) {
        return (filterComplement(predicate), filter(predicate))
    }
}

extension FlowNetwork where Weight == WeightLabel<Edge> {
    
    /// - Returns: A compressed version of the FlowNetwork where edge labels are grouped according
    /// to the nodes that the original `Node` type map to under `f`.
    /// `compress` can be thought of as the opposite of a pullback.
    /// - TODO: Implement `compress ( ... ) -> FlowNetwork< ... >`
    func compress <CompressedNode: Hashable> (_ f: @escaping (Node) -> CompressedNode) ->
        WeightedDirectedGraph<CompressedNode, [WeightLabel<OrderedPair<CompressedNode>>]>
    {
        return WeightedDirectedGraph(
            Set<CompressedNode>(self.nodes.map(f)),
            self.weights.reduce(
                into: [OrderedPair<CompressedNode>: [WeightLabel<OrderedPair<CompressedNode>>]]())
                { weightLabels, pair in
                    let edge = OrderedPair<CompressedNode>(f(pair.0.a), f(pair.0.b))
                    let weightLabel = WeightLabel<OrderedPair<CompressedNode>>(
                        edge: edge,
                        plus: Set(pair.1.plusColumn.map { edge in
                            .init(f(edge.a), f(edge.b))
                    }),
                        minus: Set(pair.1.minusColumn.map { edge in
                            .init(f(edge.a), f(edge.b))
                        })
                    )
                    if !weightLabels.keys.contains(edge) {
                        weightLabels[edge] = []
                    }
                    weightLabels[edge]!.append(weightLabel)
            }
        )
    }
    
    func renderWeights <CompressedNode: Hashable> (_ f: @escaping (Node) -> CompressedNode) ->
        WeightedDirectedGraph<CompressedNode, Double> {
            let compressed = self.compress(f)
            return WeightedDirectedGraph(
                compressed.nodes,
                compressed.weights.reduce(
                    into: [OrderedPair<CompressedNode>: Double](), compressed.inoutReducer
                )
            )
    }
}

extension WeightedDirectedGraph where Weight == [WeightLabel<Edge>] {
    
    func inoutReducer (_ concreteWeights: inout [Edge: Double],
                       _ weightPair: (key: Edge, value : [WeightLabel<Edge>])) {
        let edge = weightPair.key
        
        func getConcreteWeight (_ edge: Edge) -> Double {
            if concreteWeights.keys.contains(edge) {
                return concreteWeights[edge]!
            } else {
                let concreteWeight: Double = weight(edge).flatMap { weightLabelList in
                    weightLabelList.map { weightLabel in
                        weightLabel.minusColumn.map { getConcreteWeight($0) }.reduce(0,+)
                        }.max()
                    } ?? 0 + 1
                concreteWeights[edge] = concreteWeight
                return concreteWeight
            }
        }
        _ = getConcreteWeight(edge)
    }
}

extension FlowNetwork: Equatable { }
extension FlowNetwork: Hashable where Weight: Hashable { }
