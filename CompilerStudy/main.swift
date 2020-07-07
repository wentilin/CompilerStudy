//
//  main.swift
//  CompilerStudy
//
//  Created by wentilin on 2020/7/4.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Foundation

let text = "1 + 3 - (4 - 4 * 5)"
let lexer = Lexer(text)
let parser = Parser(lexer: lexer)
print(parser.firstCollection)
print(parser.followCollection)
print(parser.enhanceFirstCollection)

print("Begin parse: \(text)")
do {
    let result = try parser.parse()
    print("Parse result: \(result)")
} catch {
    print("Parse failed: \(error)")
}
