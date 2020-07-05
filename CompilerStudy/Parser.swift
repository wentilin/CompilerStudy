/*
    Expr  ->  Term Expr'
    Expr' ->  + Term Expr'
            | - Term Expr'
            | e
    Term  ->  Factor Term'
    Term' ->  / Factor Term'
            | * Factor Term'
            | e
    Factor -> ( Expr )
            | num
            | name
*/

enum NodeType {
    case nonterminal
    case terminal
    case epsilon
}

protocol Node: CustomStringConvertible {
    var value: String { get }
    
    var type: NodeType { get }
}

extension Node {
    var description: String { return value }
}

struct NodeWrapper: Hashable, CustomStringConvertible {
    let node: Node
    private static var _cache: [String: NodeWrapper] = [:]
    
    static var epsilonWrapper: NodeWrapper = .init(Epsilon.default)
    
    private init(_ node: Node) {
        self.node = node
    }
    
    static func with(_ node: Node) -> NodeWrapper {
        if let wrapper = _cache[node.value] {
            return wrapper
        }
        
        let wrapper = NodeWrapper(node)
        _cache[node.value] = wrapper
        
        return wrapper
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(node.value)
    }
    
    static func == (lhs: NodeWrapper, rhs: NodeWrapper) -> Bool {
        return lhs.node.value == rhs.node.value
    }
    
    var description: String { return node.value }
}

extension Node {
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

enum NonterminalNode: String, Node {
    case expr = "expr"
    case expr_ = "expr_"
    case term = "term"
    case term_ = "term_"
    case factor = "factor"
    
    var value: String { rawValue }
    var type: NodeType { .nonterminal }
}

enum TerminalNode: String, Node {
    case plus = "+"
    case minus = "-"
    case divide = "/"
    case multiply = "*"
    case num = "num"
    case name = "name"
    case leftParenthesis = "("
    case rightParenthesis = ")"
    
    var value: String { rawValue }
    var type: NodeType { .terminal }
}

struct Epsilon: Node {
    static let `default`: Epsilon = Epsilon()
    
    var value: String { "e" }
    
    var type: NodeType { .epsilon }
}

struct Production {
    let left: NonterminalNode
    let right: [Node]
}

struct FirstCollection: CustomStringConvertible {
    let node: Node
    var items: [Node]
    
    var description: String {
        return "\(node.value): \(items)"
    }
}

class Parser {
    /// Terminal collection
    let TVS: [TerminalNode] = [.plus, .minus, .divide, .multiply, .num, .name, .leftParenthesis, .rightParenthesis]
    
    /// Nonterminal collection
    let NTVS: [NonterminalNode] = [.expr, .expr_, .term, .term_, .factor]
    
    /// Proction collection
    let productions: [Production] = [
        Production(left: .expr, right: [NonterminalNode.term, NonterminalNode.expr_]),
        Production(left: .expr_, right: [TerminalNode.plus, NonterminalNode.term, NonterminalNode.expr_]),
        Production(left: .expr_, right: [TerminalNode.minus, NonterminalNode.term, NonterminalNode.expr_]),
        Production(left: .expr_, right: [Epsilon.default]),
        Production(left: .term, right: [NonterminalNode.factor, NonterminalNode.term_]),
        Production(left: .term_, right: [TerminalNode.divide, NonterminalNode.factor, NonterminalNode.term_]),
        Production(left: .term_, right: [TerminalNode.multiply, NonterminalNode.factor, NonterminalNode.term_]),
        Production(left: .term_, right: [Epsilon.default]),
        Production(left: .factor, right: [TerminalNode.leftParenthesis, NonterminalNode.expr, TerminalNode.rightParenthesis]),
        Production(left: .factor, right: [TerminalNode.num]),
        Production(left: .factor, right: [TerminalNode.name]),
    ]
    
    func produceFirstCollection() -> [FirstCollection] {
        produceFirstCollection(productions, TVS: TVS, NTVS: NTVS)
    }
    
    private func produceFirstCollection(_ productions: [Production], TVS: [TerminalNode], NTVS: [NonterminalNode]) -> [FirstCollection] {
        var fCollection: [NodeWrapper: Set<NodeWrapper>] = [:]
        
        // terminate
        for t in TVS {
            fCollection[NodeWrapper.with(t)] = [NodeWrapper.with(t)]
        }
        
        // epsilon
        fCollection[NodeWrapper.epsilonWrapper] = [NodeWrapper.epsilonWrapper]
        
        // noterminate
        for t in NTVS {
            fCollection[NodeWrapper.with(t)] = []
        }
        
        var hasChanged: Bool = true
        while hasChanged {
            hasChanged = false
            for production in productions {
                let rightNodes = production.right
                var rhs = fCollection[NodeWrapper.with(production.right[0])]!
                rhs.remove(NodeWrapper.epsilonWrapper)
                var i = 0
                if !rightNodes.contains(where: { (node) -> Bool in
                    return node.value == Epsilon.default.value
                }) {
                    while i < (production.right.count-1), fCollection[NodeWrapper.with(production.right[i])]!.contains(NodeWrapper.epsilonWrapper) {
                        
                        let next = fCollection[NodeWrapper.with(production.right[i+1])]!
                        rhs.formUnion(next)
                        rhs.remove(.epsilonWrapper)
                        i += 1
                    }
                }
                
                if i == production.right.count-1, fCollection[NodeWrapper.with(production.right[i])]!.contains(NodeWrapper.epsilonWrapper) {
                    rhs.insert(.epsilonWrapper)
                }
                
                
                let beforeCount = fCollection[NodeWrapper.with(production.left)]!.count
                fCollection[NodeWrapper.with(production.left)]!.formUnion(rhs)
                let afterCount = fCollection[NodeWrapper.with(production.left)]!.count
                hasChanged = hasChanged || (beforeCount != afterCount)
            }
        }
        
        return fCollection.map({ FirstCollection(node: $0.key.node, items: Array($0.value).map({ $0.node })) })
    }
}
