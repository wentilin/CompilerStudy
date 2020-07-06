//
//  main.swift
//  CompilerStudy
//
//  Created by wentilin on 2020/7/4.
//  Copyright © 2020 wentilin. All rights reserved.
//

import Foundation

let lexer = Lexer("1 + 3 - (4 - 4 * 5)")
let parser = Parser(lexer: lexer)
print(parser.firstCollection)
print(parser.followCollection)
print(try? parser.parse())
