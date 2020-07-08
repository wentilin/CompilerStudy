//
//  Lexer.swift
//  CompilerStudy
//
//  Created by linwenhu on 2020/7/6.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Foundation

struct LexerToken {
    enum TokenType: String {
        case plus = "+"
        case minus = "-"
        case divide = "/"
        case multiply = "*"
        case num = "num"
        case name = "name"
        case leftParenthesis = "("
        case rightParenthesis = ")"
        case eof = "eof"
    }
    
    var value: Any
    var type: TokenType
}

class Lexer {
    var stack: [String] = []
    private var currentChar: String?
    
    init(_ text: String) {
        for char in text {
            stack.insert(String(char), at: 0)
        }
        
        currentChar = stack.last
    }
    
    func nextToken() throws -> LexerToken {
        while let char = currentChar {
            if char == " " {
                skpWhitespace()
                continue
            }
        
            if Int(char) != nil {
                return .init(value: integer(), type: .num)
            }
            
            if char == "+" {
                advance()
                return .init(value: "+", type: .plus)
            }
            
            if char == "-" {
                advance()
                return .init(value: "-", type: .minus)
            }
            
            if char == "*" {
                advance()
                return .init(value: "*", type: .multiply)
            }
            
            if char == "/" {
                advance()
                return .init(value: "/", type: .divide)
            }
            
            if char == "(" {
                advance()
                return .init(value: "(", type: .leftParenthesis)
            }
            
            if char == ")" {
                advance()
                return .init(value: ")", type: .rightParenthesis)
            }
            
            throw NSError(domain: "Invalid character", code: -1, userInfo: nil)
        }
        
        return .init(value: "eof", type: .eof)
    }
    
    private func advance() {
        if stack.isEmpty {
            currentChar = nil
        } else {
            stack.removeLast()
            currentChar = stack.last
        }
    }
    
    private func skpWhitespace() {
        while currentChar != nil, currentChar! == " " {
            advance()
        }
    }
    
    private func integer() -> Int {
        var res = ""
        if let char = currentChar, Int(char) != nil {
            res += char
            advance()
        }
        
        return Int(res)!
    }
}

extension Lexer: CustomStringConvertible {
    var description: String {
        return stack.reversed().joined()
    }
}
