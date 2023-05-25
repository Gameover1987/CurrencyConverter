
import Foundation

final class CurrencySelectorViewModel {
    
    private let currencyApi: CurrencyApiProtocol
    
    init (currencyApi: CurrencyApiProtocol) {
        self.currencyApi = currencyApi
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
        for currencyPair in allCurrencyPairs {
            allCurrencies += currencyPair.toArray()
        }
        
        let allCurrrenciesUnique = allCurrencies.distinct().sorted()
        
        currencyList = allCurrrenciesUnique
    }
}

private class CurrencyPair {
    
    private let currencyA: String
    private let currencyB: String
    
    init (_ currencyPairAsString: String) {
        self.currencyA = currencyPairAsString[0..<3]
        self.currencyB = currencyPairAsString[3...]
    }
    
    func toArray() -> [String] {
        return [currencyA, currencyB]
    }
}
