//
//  LRParser.swift
//  CompilerStudy
//
//  Created by linwenhu on 2020/7/10.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Foundation

class LRParser: Parser {
    /// Terminal collection
    var terminals: [TerminalNode]
    
    /// Nonterminal collection
    var nonterminals: [NonterminalNode]
    
    /// Proction collection
    var productions: [Production]
    
    var firstCollection: FirstCollection {
        return _firstCollection_
    }
    
    var collectionSet: LRConanicalCollectionSet {
        return _collectionSet_
    }
    
    var gotoCollection: LRConanicalGotoCollection {
        return _gotoCollection_
    }
    
    var analyticTable: LRAnalyticTable {
        return _analyticTable_
    }
    
    private let lexer: Lexer
    private var currentToken: LexerToken!
    
    init(lexer: Lexer, terminals: [TerminalNode], nonterminals: [NonterminalNode], productions: [Production]) {
        self.lexer = lexer

        self.terminals = terminals
        self.nonterminals = nonterminals
        self.productions = productions
        
        _firstCollection_ = LRParseCollectionConstructor.produceFirstCollection(productions, terminals: terminals, nonterminals: nonterminals)
        (_collectionSet_, _gotoCollection_) = LRParseCollectionConstructor.produceConanicalCollectionSet(productions: productions, firstCollection: _firstCollection_)
        _analyticTable_ = LRParseCollectionConstructor.produceAnalyticTable(collectionSet: _collectionSet_, gotoCollection: _gotoCollection_, nonterminals: nonterminals)
        
    }
    
    func parse() throws -> Bool {
        var stack: [Any] = []
        stack.append(EOFNode.default)
        stack.append(collectionSet[0].order)
        currentToken = try lexer.nextToken()
        
        print(stack)
        
        while true {
            var state = stack.last as! Int
            let actionType = analyticTable.actionCollection[state, currentToken.node]
            switch actionType {
            case .shift(let order):
                stack.append(currentToken.node)
                stack.append(order)
                currentToken = try lexer.nextToken()
                break
            case .reduce(let production):
                for _ in 0..<2*production.right.count {
                    stack.removeLast()
                }
                state = stack.last as! Int
                stack.append(production.left)
                guard let goto = analyticTable.gotos[state, production.left] else {
                    throw NSError(domain: "LR(1) parse fail.", code: -1, userInfo: ["info": "goto<\(state), \(production.left.value)> not found"])
                }
                
                stack.append(goto)
                break
            case .accept:
                return true
            case .none:
                throw NSError(domain: "LR(1) parse fail.", code: -1, userInfo: nil)
            }
            
            print(stack)
        }
    }
    
    private var _firstCollection_: FirstCollection = .init([])
    private var _analyticTable_: LRAnalyticTable
    private var _collectionSet_: LRConanicalCollectionSet
    private var _gotoCollection_: LRConanicalGotoCollection
}
