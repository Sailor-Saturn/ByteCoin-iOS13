//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didFailWithError(error: Error)
    func didUpdateCoin(currency: String, price: String)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "YOUR_API_KEY_HERE"
    
    var delegate: CoinManagerDelegate?
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String){
        let url = "\(baseURL)/\(currency)?apiKey=\(Keys.id)"
        performRequest(with: url, and: currency)
    }
    
    func performRequest(with urlString: String, and currency: String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, url, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let coin = self.parseJSON(safeData){
                        let priceString = String(format: "%.2f", coin)
                        self.delegate?.didUpdateCoin(currency: currency, price: priceString)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ coinData: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let rate = decodedData.rate
            
            return rate
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
