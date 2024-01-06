//
//  ExchangeRate.swift
//  CurrencyConverter
//
//  Created by Lofy on 06/01/24.
//

import Foundation

struct ExchangeRate: Codable {
    let from: String
    let to: String
    let rate: Float
}

struct ExchangeRateResponse: Codable {
    let data: [String: Float]
    
    func toExchangeRate(from: String, to: String) -> ExchangeRate {
        return ExchangeRate(from: from, to: to, rate: data[to] ?? 0.0)
    }
}

enum ExchangeRateRequestErrorType {
    case server
    case client
    case decode
}

struct ExchangeRateRequestErrorDetail {
    let error: Error
    let type: ExchangeRateRequestErrorType
}

protocol ExchangeRateResponseDelegate {
    func reset()
    func requestFailedWith(error: Error?, type: ExchangeRateRequestErrorType)
}

class ExchangeRateDelegate: ExchangeRateResponseDelegate, ObservableObject {
    @Published var isErrorState: Bool = false
    @Published var errorDetail: ExchangeRateRequestErrorDetail? = nil
    
    func reset() {
        DispatchQueue.main.async {
            self.isErrorState = false
            self.errorDetail = nil
        }
    }
    
    func requestFailedWith(error: Error?, type: ExchangeRateRequestErrorType) {
        DispatchQueue.main.async {
            self.isErrorState = true
            if let err = error {
                self.errorDetail = ExchangeRateRequestErrorDetail(error: err, type: type)
            }
        }
    }
}
