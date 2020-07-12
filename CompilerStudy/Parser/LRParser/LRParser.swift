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
        return true
    }
    
    private var _firstCollection_: FirstCollection = .init([])
    private var _analyticTable_: LRAnalyticTable
    private var _collectionSet_: LRConanicalCollectionSet
    private var _gotoCollection_: LRConanicalGotoCollection
}
