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

import Foundation

class Production: NSObject {
    let left: NonterminalNode
    let right: [Node]
    
    init(left: NonterminalNode, right: [Node]) {
        self.left = left
        self.right = right
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
    
    var firstCollection: FirstCollection {
        return _firstCollection_
    }
    
    var followCollection: FollowCollection {
        return _followCollection_
    }
    
    private let lexer: Lexer
    private var currentToken: LexerToken!
    
    init(lexer: Lexer) {
        self.lexer = lexer

        _firstCollection_ = produceFirstCollection()
        _followCollection_ = produceFollowCollection()
    }
    
    func produceFirstCollection() -> FirstCollection {
        produceFirstCollection(productions, TVS: TVS, NTVS: NTVS)
    }
    
    func produceFollowCollection() -> FollowCollection {
        produceFollowCollection(productions, TVS: TVS, NTVS: NTVS, firstCollection: _firstCollection_)
    }
    
    private var _firstCollection_: FirstCollection = .init([])
    private var _followCollection_: FollowCollection = .init([])
    private var _enhanceFirstCollection: EnhanceFirstCollection = .init([:])
}

extension Parser {
    private func produceFirstCollection(_ productions: [Production], TVS: [TerminalNode], NTVS: [NonterminalNode]) -> FirstCollection {
        var fCollection: [NodeWrapper: Set<NodeWrapper>] = [:]
        
        // terminate
        for t in TVS {
            fCollection[NodeWrapper.with(t)] = [NodeWrapper.with(t)]
        }
        
        // epsilon
        fCollection[NodeWrapper.epsilonWrapper] = [NodeWrapper.epsilonWrapper]
        
        // eof
        fCollection[NodeWrapper.eofWrapper] = [NodeWrapper.eofWrapper]
        
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
        
        let items = fCollection.map({ FirstItem(node: $0.key.node, items: Array($0.value).map({ $0.node })) })
        
        return .init(items)
    }
    
    private func produceFollowCollection(_ productions: [Production], TVS: [TerminalNode], NTVS: [NonterminalNode], firstCollection: FirstCollection) -> FollowCollection {
        var followCollection: [NodeWrapper: Set<NodeWrapper>] = [:]
        
        // set empty
        for item in NTVS {
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
}

extension Parser {
    func parse() throws -> Bool {
        try main()
    }
    
    private func main() throws -> Bool {
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
    
    private func expr() throws -> Bool {
        if try term() {
            return try exprPrime()
        }
        
        throw error(with: "Unknow expression")
    }
    
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
    
    private func term() throws -> Bool {
        if try factor() {
            return try termPrime()
        }
        
        throw error(with: "Unknow expression")
    }
    
    private func termPrime() throws -> Bool {
        if currentToken.type == .divide || currentToken.type == .mutiply {
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
