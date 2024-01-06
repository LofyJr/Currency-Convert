//
//  ContentView.swift
//  CurrencyConverter
//
//  Created by Lofy on 05/01/24.
//

import SwiftUI

struct ContentView: View {
    @State var currencies = CurrencyState.currencies
    @State var amount: String = "100.0"
    @State var convertedAmount: String? = nil
    @State var fromCurrency: Currency = CurrencyState.currencies[0]
    @State var toCurrency: Currency = CurrencyState.currencies[1]
    @State var isLoading: Bool = false
    @State var showErrorScreen: Bool = false
    @ObservedObject var errorDelegate =  ExchangeRateDelegate()
    
    var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = "."
        
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 20){
            Text("Currency Converter")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.appColor)
                .padding()
            
            Image("currency-exchange")
                .resizable()
                .frame(width: 100, height: 100)
            
            Text("You Converted Amount")
                .font(.title3)
            
            HStack{
                if isLoading {
                    ProgressView()
                }else {
                    Text(getConvertedAmountString())
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
            .frame(width: 350, height: 80)
            .background(Color.appColor)
            .cornerRadius(12)
            
            VStack(alignment: .leading){
                Text("Convert Amount")
                    .font(.title3)
                    .padding()
                
                TextField("", text: $amount)
                    .font(.system(size: 22))
                    .padding(10)
                    .frame(width: 350, height: 50)
                    .background(.gray.opacity(0.2))
                    .cornerRadius(12)
            }
            
            HStack{
                Text("From Currency")
                
                Spacer()
                
                Picker("From Currency", selection: $fromCurrency) {
                    ForEach(currencies, id: \.code){ currenci in
                        Text(currenci.code).tag(currenci)
                    }
                }
            }
            
            HStack{
                Text("To Currency")
                
                Spacer()
                
                Picker("To Currency", selection: $toCurrency) {
                    ForEach(currencies, id: \.code){ currenci in
                        Text(currenci.code).tag(currenci)
                    }
                }
            }
            
            Button {
                converCurrency()
            } label: {
                Text("Convert")
                    .frame(width: 350, height: 50)
                    .foregroundColor(.white)
                    .background(Color.appColor)
                    .cornerRadius(12)
            }

        }
        .padding(.top, 30)
        .padding(.leading, 30)
        .padding(.trailing, 30)
        .fullScreenCover(isPresented: $showErrorScreen) {
            ErrorView()
        }
        .onChange(of: errorDelegate.isErrorState) { newValue in
            if newValue {
                isLoading = false
                showErrorScreen = true
            }
        }
    }
    
    func getConvertedAmountString() -> String {
        return convertedAmount ?? "\(fromCurrency.symbol) \(amount)"
    }
    
    func converCurrency() -> Void {
        guard let floatAmount = formatter.number(from: amount) as? Float else
        { return }
        isLoading = true
        
        DispatchQueue.global(qos: .background).async {
            let rateManager = ExchangeRateManager()
            rateManager.delegate = errorDelegate
            rateManager.fetchRates(for: fromCurrency.code, toCurrency: toCurrency.code) { result in
                
                if let exchangeRate = result {
                    let convertedAmountFloat = exchangeRate.rate * floatAmount
                    let convertedAmountString = formatter.string(from: NSNumber(value: convertedAmountFloat)) ?? "0.00"
                    
                    DispatchQueue.main.async {
                        isLoading = false
                        self.convertedAmount = "\(toCurrency.symbol) \(convertedAmountString)"
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
