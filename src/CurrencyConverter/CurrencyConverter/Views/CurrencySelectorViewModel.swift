
import Foundation

final class CurrencySelectorViewModel {
    
    private let currencyApi: CurrencyApiProtocol
    
    init (currencyApi: CurrencyApiProtocol, selectedCurrency: String) {
        self.currencyApi = currencyApi
        self.selectedCurrency = selectedCurrency
    }
    
    var selectedCurrency: String = "" {
        didSet {
            currencySelectedAction?(selectedCurrency)
        }
    }
    
    var currencyList: [String] = []
    
    var currencySelectedAction: ((String) -> Void)?
    
    func fetch(for currency: String, completion: @escaping (Result<[String], Error>) -> Void) {
        currencyApi.performCurrencyListRequest { [weak self] result in
            
            guard let self = self else {return}
            
            switch result {
            case .failure(let error):
                print(error)
                
            case .success(let response):
                
                self.fillCurrencyList(for: currency, source: response.data)
                
                completion(.success(response.data))
            }
        }
    }
    
    private func fillCurrencyList(for currency: String, source: [String]) {
        currencyList.removeAll()
        
        let allCurrencyPairs = source.map { pairAsString in
            return CurrencyPair(pairAsString)
        }
             
        var allCurrencies:[String] = []
        
        // Если нет выбранной валют то показываем все валюты валфавитном порядке
        if (currency.isEmpty) {
            for currencyPair in allCurrencyPairs {
                allCurrencies += currencyPair.toArray()
            }
            
            currencyList = allCurrencies.distinct().sorted()
        } else {
            // В противном случае показываем только те что сочетаются с выбранной валютой
            let supportedCurrencyPairs = allCurrencyPairs.filter { pair in
                return pair.contains(currency)
            }

            for currencyPair in supportedCurrencyPairs {
                allCurrencies += currencyPair.toArray()
            }
            currencyList = allCurrencies.distinct().sorted()
        }
    }
}
