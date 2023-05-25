
import Foundation

protocol CurrencyApiProtocol {
    func performCurrencyListRequest(completion: @escaping (Result<CurrencyListReponse, Error>) -> Void)
    
    func performCurrencyRateRequest(pairAsString: String, completion: @escaping (Result<CurrencyRate, Error>) -> Void)
}
