//
//  Parser.swift
//  CompilerStudy
//
//  Created by linwenhu on 2020/7/10.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Foundation

protocol Parser {
    /// Terminal collection
    var terminals: [TerminalNode] { get set }
    
    /// Nonterminal collection
    var nonterminals: [NonterminalNode] { get set }
    
    /// Proction collection
    var productions: [Production] { get set }
    
    func parse() throws -> Bool
}
