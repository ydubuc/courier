//
//  Terror.swift
//  
//
//  Created by Yoan Dubuc on 9/7/22.
//

import Foundation

struct Terror: Error {
    // properties
    let message: String
    let code: Int?

    // init
    init(_ message: String, code: Int? = 0) {
        self.message = message
        self.code = code
    }
}

extension Terror: LocalizedError {
    var errorDescription: String? { return message }
}
