
import Foundation

protocol CurrencyApiProtocol {
    func performCurrencyListRequest(completion: @escaping (Result<CurrencyListReponse, Error>) -> Void)
    
    func performCurrencyRateRequest(pair: String, completion: @escaping (Result<CurrencyRatesResponse, Error>) -> Void)
}


