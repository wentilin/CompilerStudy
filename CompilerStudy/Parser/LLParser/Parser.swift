import Foundation

/// Expr  ->  Term Expr'
/// Expr' ->  + Term Expr'
///       | - Term Expr'
///       | e
/// Term  ->  Factor Term'
/// Term' ->  / Factor Term'
///       | * Factor Term'
///       | e
/// Factor -> ( Expr )
///       | num
///       | name
class Parser {
    /// Terminal collection
    let terminals: [TerminalNode] = ParseRule.default.terminals
    
    /// Nonterminal collection
    let nonterminals: [NonterminalNode] = ParseRule.default.nonterminals
    
    /// Proction collection
    let productions: [Production] = ParseRule.default.productions
    
    var firstCollection: FirstCollection {
        return _firstCollection_
    }
    
    var followCollection: FollowCollection {
        return _followCollection_
    }
    
    var enhanceFirstCollection: EnhanceFirstCollection {
        return _enhanceFirstCollection_
    }
    
    var analyticTable: AnalyticTable {
        return _analyticTable_
    }
    
    private let lexer: Lexer
    private var currentToken: LexerToken!
    
    init(lexer: Lexer) {
        self.lexer = lexer

        _firstCollection_ = produceFirstCollection()
        _followCollection_ = produceFollowCollection()
        _enhanceFirstCollection_ = produceEnhanceFirstCollection()
        _analyticTable_ = produceAnalyticTable()
    }
    
    func produceFirstCollection() -> FirstCollection {
        produceFirstCollection(productions, terminals: terminals, nonterminals: nonterminals)
    }
    
    func produceFollowCollection() -> FollowCollection {
        produceFollowCollection(productions, terminals: terminals, nonterminals: nonterminals, firstCollection: _firstCollection_)
    }
    
    func produceEnhanceFirstCollection() -> EnhanceFirstCollection {
        produceEnchanceFisrtCollection(productions: productions, firstCollection: firstCollection, followCollection: followCollection)
    }
    
    func produceAnalyticTable() -> AnalyticTable {
        produceAnalyticTable(productions: productions, nonterminals: nonterminals, enhanceFirstCollection: enhanceFirstCollection)
    }
    
    private var _firstCollection_: FirstCollection = .init([])
    private var _followCollection_: FollowCollection = .init([])
    private var _enhanceFirstCollection_: EnhanceFirstCollection = .init([:])
    private var _analyticTable_: AnalyticTable = .init()
}

extension Parser {
    private func produceFirstCollection(_ productions: [Production], terminals: [TerminalNode], nonterminals: [NonterminalNode]) -> FirstCollection {
        var fCollection: [NodeWrapper: Set<NodeWrapper>] = [:]
        
        // terminate
        for t in terminals {
            fCollection[NodeWrapper.with(t)] = [NodeWrapper.with(t)]
        }
        
        // epsilon
        fCollection[NodeWrapper.epsilonWrapper] = [NodeWrapper.epsilonWrapper]
        
        // eof
        fCollection[NodeWrapper.eofWrapper] = [NodeWrapper.eofWrapper]
        
        // noterminate
        for t in nonterminals {
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
        
        let items = fCollection.map({ FirstItem(node: $0.key.node, items: Array($0.value).map({ $0.node })) })
        
        return .init(items)
    }
    
    private func produceFollowCollection(_ productions: [Production], terminals: [TerminalNode], nonterminals: [NonterminalNode], firstCollection: FirstCollection) -> FollowCollection {
        var followCollection: [NodeWrapper: Set<NodeWrapper>] = [:]
        
        // set empty
        for item in nonterminals {
            followCollection[NodeWrapper.with(item)] = []
        }
        
        // start
        followCollection[.with(productions[0].left)] = [.eofWrapper]
        
        var hasChanged = true
        while hasChanged {
            hasChanged = false
            for production in productions {
                var trailer = followCollection[NodeWrapper.with(production.left)]!
                for i in 0..<production.right.count {
                    let j = production.right.count - 1 - i
                    let node = production.right[j]
                    let fisrtItem = Set<NodeWrapper>(firstCollection[node].map({ NodeWrapper.with($0) }))
                    if node.type == .nonterminal {
                        let beforeCount = followCollection[NodeWrapper.with(node)]!.count
                        followCollection[NodeWrapper.with(node)]!.formUnion(trailer)
                        let afterCount = followCollection[NodeWrapper.with(node)]!.count
                        
                        hasChanged = hasChanged || (beforeCount != afterCount)
                        
                        let containsEpsilon = firstCollection[node].contains{ $0.value == Epsilon.default.value }
                        if containsEpsilon {
                            trailer.formUnion(fisrtItem)
                            trailer.remove(.epsilonWrapper)
                        } else {
                            trailer = Set<NodeWrapper>(fisrtItem)
                        }
                    } else {
                        trailer = Set<NodeWrapper>(fisrtItem)
                    }
                }
            }
        }
        
        let items = followCollection.map({ FollowItem(node: $0.key.node as! NonterminalNode, items: Array($0.value).map({ $0.node })) })
        
        return .init(items)
    }
    
    private func produceEnchanceFisrtCollection(productions: [Production], firstCollection: FirstCollection, followCollection: FollowCollection) -> EnhanceFirstCollection {
        var fCollection: [Production: [Node]] = [:]
        
        for production in productions {
            let rightNodes = production.right
            var rhs = Set<NodeWrapper>(firstCollection[production.right[0]].map({ NodeWrapper.with($0)}))
            
            var i = 0
            if !rightNodes.contains(where: { (node) -> Bool in
                return node.value == Epsilon.default.value
            }) {
                while i < (production.right.count-1), firstCollection[production.right[i]].contains(where: { (node) -> Bool in
                    return node.value == Epsilon.default.value
                }) {
                    
                    let next = Set<NodeWrapper>(firstCollection[production.right[i+1]].map({ NodeWrapper.with($0)}))
                    rhs.formUnion(next)
                    rhs.remove(.epsilonWrapper)
                    i += 1
                }
                
                if i == production.right.count-1, firstCollection[production.right[i]].contains(where: { (node) -> Bool in
                    return node.value == Epsilon.default.value
                }) {
                    rhs.insert(.epsilonWrapper)
                }
            }
            
            if rhs.contains(where: { wrapper in
                wrapper.node.value == Epsilon.default.value
            }) {
                rhs.formUnion(Set<NodeWrapper>(followCollection[production.left].map({ NodeWrapper.with($0) })))
            }
            
            fCollection[production] = Array(rhs).map({ $0.node })
        }
        
        return .init(fCollection)
    }
    
    private func produceAnalyticTable(productions: [Production], nonterminals: [NonterminalNode], enhanceFirstCollection: EnhanceFirstCollection) -> AnalyticTable {
        var table = AnalyticTable()
        
        for production in productions {
            for node in enhanceFirstCollection[production] {
                if node.type == .terminal {
                    table[production.left, node] = production
                }
            }
            
            if enhanceFirstCollection[production].contains(where: { $0.value == EOFNode.default.value}) {
                table[production.left, EOFNode.default] = production
            }
        }
        
        return table
    }
}

extension Parser {
    func parse() throws -> Bool {
//        try parseByRecursiveDesent()
        try parseByLL1()
    }
    
    /// Start parsing
    private func parseByRecursiveDesent() throws -> Bool {
        currentToken = try lexer.nextToken()
        if try expr() {
            if currentToken.type == .eof {
                return true
            } else {
                throw error(with: "Unknow expression")
            }
        }
        
        throw error(with: "Unknow expression")
    }
    
    /// Expr  ->  Term Expr'
    private func expr() throws -> Bool {
        if try term() {
            return try exprPrime()
        }
        
        throw error(with: "Unknow expression")
    }
    
    /// Expr' ->  + Term Expr'
    ///       | - Term Expr'
    ///       | e
    private func exprPrime() throws -> Bool {
        if currentToken.type == .plus || currentToken.type == .minus {
            currentToken = try lexer.nextToken()
            
            if try term() {
                return try exprPrime()
            } else {
                throw error(with: "Unknow expression")
            }
        } else if currentToken.type == .eof ||
            currentToken.type == .rightParenthesis { // Expr' -> ε
            return true
        } else {
            throw error(with: "Unknow expression")
        }
    }
    
    /// Term  ->  Factor Term'
    private func term() throws -> Bool {
        if try factor() {
            return try termPrime()
        }
        
        throw error(with: "Unknow expression")
    }
    
    /// Term' ->  / Factor Term'
    ///       | * Factor Term'
    ///       | e
    private func termPrime() throws -> Bool {
        if currentToken.type == .divide || currentToken.type == .multiply {
            currentToken = try lexer.nextToken()
            
            if try factor() {
                return try termPrime()
            } else {
                throw error(with: "Unknow expression")
            }
        } else if currentToken.type == .plus ||
            currentToken.type == .minus ||
            currentToken.type == .rightParenthesis ||
            currentToken.type == .eof { // Term' -> ε
            return true
        } else {
            throw error(with: "Unknow expression")
        }
    }
    
    /// Factor -> ( Expr )
    ///       | num
    ///       | name
    private func factor() throws -> Bool {
        if currentToken.type == .leftParenthesis {
            currentToken = try lexer.nextToken()
            if !(try expr()) {
                throw error(with: "Unknow expression")
            }
            
            if currentToken.type != .rightParenthesis {
                throw error(with: "Can't find )")
            }
            
            currentToken = try lexer.nextToken()
            return true
        } else if currentToken.type == .num || currentToken.type == .name {
            currentToken = try lexer.nextToken()
            return true
        } else {
            throw error(with: "Unknow expression")
        }
    }
    
    private func error(with reason: String) -> NSError {
        return .init(domain: "Parse failed", code: -1, userInfo: ["reason": reason])
    }
}

extension Parser {
    func parseByLL1() throws -> Bool {
        print("LL(1) parse start")
        currentToken = try lexer.nextToken()
        var stack: [Node] = []
        stack.append(EOFNode.default)
        stack.append(NonterminalNode.expr)
        
        print("\(stack) : \(currentToken.value) \(lexer)")
        
        var focus = stack.last!
        while true {
            if focus.type == .eof, currentToken.type == .eof {
                print("LL(1) parse end")
                return true
            } else if focus.type == .terminal || focus.type == .eof {
                if let node = (focus as? TerminalNode), node.matches(currentToken)  {
                    stack.removeLast()
                    currentToken = try lexer.nextToken()
                    
                    print("\(stack) : \(currentToken.value) \(lexer)")
                } else {
                    throw error(with: "LL1 parse failed.[ \(focus.value) not matches \(currentToken.value) ]")
                }
            } else {
                if let production = analyticTable[focus as! NonterminalNode, currentToken.node] {
                    stack.removeLast()
                    for i in 0..<production.right.count {
                        let node = production.right[production.right.count - 1 - i]
                        if node.type != .epsilon {
                            stack.append(node)
                        }
                    }
                    print("\(stack) : \(currentToken.value) \(lexer)")
                } else {
                    throw error(with: "LL1 parse failed.[ \(focus.value) not matches \(currentToken.value) ]")
                }
            }
            
            focus = stack.last!
        }
    }
}

extension TerminalNode {
    func matches(_ token: LexerToken) -> Bool {
        return token.type.rawValue == self.rawValue
    }
}

extension LexerToken {
    var node: Node {
        switch self.type {
        case .eof:
            return EOFNode.default
        default:
            return TerminalNode(rawValue: self.type.rawValue)!
        }
    }
}
