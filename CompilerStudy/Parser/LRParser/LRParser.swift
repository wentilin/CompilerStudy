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
    
    private let lexer: Lexer
    private var currentToken: LexerToken!
    
    init(lexer: Lexer, terminals: [TerminalNode], nonterminals: [NonterminalNode], productions: [Production]) {
        self.lexer = lexer

        self.terminals = terminals
        self.nonterminals = nonterminals
        self.productions = productions
        
        _firstCollection_ = LLParseCollectionConstructor.produceFirstCollection(productions, terminals: terminals, nonterminals: nonterminals)
    }
    
    func parse() throws -> Bool {
        return true
    }
    
    private var _firstCollection_: FirstCollection = .init([])
}
