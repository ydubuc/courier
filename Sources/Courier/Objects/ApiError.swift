//
//  Terror.swift
//  
//
//  Created by Yoan Dubuc on 9/7/22.
//

import Foundation

struct ApiError: Codable, Error {
    let statusCode: Int
    let message: [String]

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        statusCode = try values.decode(Int.self, forKey: .statusCode)

        // the json from the api response can be either a single string or an array
        // we check first to see if we can convert the single string to an array
        if let singleMessage = try? values.decode(String.self, forKey: .message) {
            message = [singleMessage]
        } else {
            message = try values.decode([String].self, forKey: .message)
        }
    }
}
