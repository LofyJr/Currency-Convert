//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Lofy on 05/01/24.
//

import Foundation


struct Currency: Hashable {
    let code: String
    let symbol: String
}

class CurrencyState {
    static let currencies: [Currency] = [
        Currency(code: "USD", symbol: "$"),
        Currency(code: "EUR", symbol: "€"),
        Currency(code: "GBP", symbol: "£"),
        Currency(code: "CAD", symbol: "$")
    ]
}
