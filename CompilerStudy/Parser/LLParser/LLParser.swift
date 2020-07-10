import Foundation

/// Goal ->   Expr
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
class LLParser: Parser {
    /// Terminal collection
    var terminals: [TerminalNode]
    
    /// Nonterminal collection
    var nonterminals: [NonterminalNode]
    
    /// Proction collection
    var productions: [Production]
    
    var firstCollection: FirstCollection {
        return _firstCollection_
    }
    
    var followCollection: FollowCollection {
        return _followCollection_
    }
    
    var enhanceFirstCollection: EnhanceFirstCollection {
        return _enhanceFirstCollection_
    }
    
    var analyticTable: LLAnalyticTable {
        return _analyticTable_
    }
    
    private let lexer: Lexer
    private var currentToken: LexerToken!
    
    init(lexer: Lexer, terminals: [TerminalNode], nonterminals: [NonterminalNode], productions: [Production]) {
        self.lexer = lexer

        self.terminals = terminals
        self.nonterminals = nonterminals
        self.productions = productions
        
        _firstCollection_ = produceFirstCollection()
        _followCollection_ = produceFollowCollection()
        _enhanceFirstCollection_ = produceEnhanceFirstCollection()
        _analyticTable_ = produceLLAnalyticTable()
    }
    
    func produceFirstCollection() -> FirstCollection {
        LLParseCollectionConstructor.produceFirstCollection(productions, terminals: terminals, nonterminals: nonterminals)
    }
    
    func produceFollowCollection() -> FollowCollection {
        LLParseCollectionConstructor.produceFollowCollection(productions, terminals: terminals, nonterminals: nonterminals, firstCollection: _firstCollection_)
    }
    
    func produceEnhanceFirstCollection() -> EnhanceFirstCollection {
        LLParseCollectionConstructor.produceEnchanceFisrtCollection(productions: productions, firstCollection: firstCollection, followCollection: followCollection)
    }
    
    func produceLLAnalyticTable() -> LLAnalyticTable {
        LLParseCollectionConstructor.produceAnalyticTable(productions: productions, nonterminals: nonterminals, enhanceFirstCollection: enhanceFirstCollection)
    }
    
    func parse() throws -> Bool {
    //        try parseByRecursiveDesent()
            try parseByLL1()
    }
    
    private var _firstCollection_: FirstCollection = .init([])
    private var _followCollection_: FollowCollection = .init([])
    private var _enhanceFirstCollection_: EnhanceFirstCollection = .init([:])
    private var _analyticTable_: LLAnalyticTable = .init()
}

extension LLParser {
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

extension LLParser {
    func parseByLL1() throws -> Bool {
        print("LL(1) parse start")
        currentToken = try lexer.nextToken()
        var stack: [Node] = []
        stack.append(EOFNode.default)
        stack.append(productions[0].left)
        
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
