//
//  Node.swift
//  CompilerStudy
//
//  Created by linwenhu on 2020/7/6.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Foundation

enum NodeType {
    case nonterminal
    case terminal
    case epsilon
    case eof
}

protocol Node: CustomStringConvertible {
    var value: String { get }
    
    var type: NodeType { get }
}

extension Node {
    var description: String { return value }
}

extension Node {
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

/// Nonterminal node
enum NonterminalNode: String, Node {
    case goal = "goal"
    case expr = "expr"
    case expr_ = "expr_"
    case term = "term"
    case term_ = "term_"
    case factor = "factor"
    
    var value: String { rawValue }
    var type: NodeType { .nonterminal }
}

/// Terminal node
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

/// Epsilon node
struct Epsilon: Node {
    static let `default`: Epsilon = Epsilon()
    
    var value: String { "e" }
    
    var type: NodeType { .epsilon }
}

/// End of file node
struct EOFNode: Node {
    static let `default`: EOFNode = EOFNode()
    
    var value: String { "eof" }
    
    var type: NodeType { .eof }
}
