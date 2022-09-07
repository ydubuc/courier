//
//  ErrorDecoder.swift
//  
//
//  Created by Yoan Dubuc on 9/7/22.
//

import Foundation

struct ApiErrorHandler {
    static func getError(data: Data?, httpRes: HTTPURLResponse) -> Terror {
        guard let data = data,
              let apiError = try? JSONDecoder().decode(ApiError.self, from: data)
        else {
            let message = "\(httpRes.statusCode) A server error occured."
            let terror = Terror(message, code: httpRes.statusCode)
            return terror
        }

        return Terror(
            apiError.message.joined(separator: ", "),
            code: apiError.statusCode
        )
    }
}
