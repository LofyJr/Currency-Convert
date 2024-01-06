//
//  ExchangeRateManager.swift
//  CurrencyConverter
//
//  Created by Lofy on 06/01/24.
//

import Foundation

class ExchangeRateManager {
    public var delegate: ExchangeRateDelegate? = nil
    static let apiKey = "fca_live_RfhAwABnf1gOUILvMEaPJ2WLWKZjZlJUNIORLOFY"
    let url = "https://api.freecurrencyapi.com/v1/latest?apikey=\(ExchangeRateManager.apiKey)"
    
    func fetchRates(for currency: String, toCurrency: String, completion: @escaping (_ exchangeRate: ExchangeRate?) -> Void ) {
        self.delegate?.reset()
        
        let url = URL(string: "\(self.url)&base_currency=\(currency)&currencies\(toCurrency)")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let err = error {
                self.handleClientError(err)
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                self.handleServerError(response)
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            if let mimeType = httpResponse.mimeType, mimeType == "application/json",
               let json = data {
                let rate = self.decodeResponse(json: json, for: currency, to: toCurrency)
                
                DispatchQueue.main.async {
                    completion(rate)
                }
            }else {
                self.handleDecodeError()
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
        }
        task.resume()
    }
    
    func decodeResponse(json: Data, for currency: String, to toCurrency: String) -> ExchangeRate? {
        do {
            let decoder = JSONDecoder()
            let exchangeRateResponse = try decoder.decode(ExchangeRateResponse.self, from: json)
            return exchangeRateResponse.toExchangeRate(from: currency, to: toCurrency)
        } catch {
            self.handleDecodeError()
            return nil
        }
    }
    
    private func handleClientError(_ error: Error) {
        delegate?.requestFailedWith(error: error, type: .client)
    }
    
    private func handleServerError(_ response: URLResponse?) {
        let error = NSError(domain: "API Error", code: 141)
        delegate?.requestFailedWith(error: error, type: .server)
    }
    
    private func handleDecodeError() {
        let error = NSError(domain: "Decode Error", code: 141)
        delegate?.requestFailedWith(error: error, type: .decode)
    }
}
