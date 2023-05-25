
import Foundation

enum ApiErrors : String, Error {
    case dataIsNil = "Data is nil!"
    case jsonParseError = "JSON parse error"
}

final class CurrencyApi : CurrencyApiProtocol {
    private var currateUrl = URLComponents(string: "https://currate.ru/api/?")
    private let currencyList = URLQueryItem(name: "get", value: "currency_list")
    private let apiKey = URLQueryItem(name: "key", value: "2a40531fd76d6dad9b120312b752c827")
    
    static var shared: CurrencyApiProtocol = CurrencyApi()
    
    private init(){
        
    }
    
    func performCurrencyListRequest(completion: @escaping (Result<CurrencyListReponse, Error>) -> Void) {
        let request = getCurrateRequest()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(ApiErrors.dataIsNil))
                return
            }
            
            do
            {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let currencyListResponse = try decoder.decode(CurrencyListReponse.self, from: data)
                completion(.success(currencyListResponse))
            }
            catch {
                print(error)
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func performCurrencyRateRequest(pair: String, completion: @escaping (Result<CurrencyRatesResponse, Error>) -> Void) {
        
    }
    
    private func getCurrateRequest() -> URLRequest {
        currateUrl?.queryItems?.append(currencyList)
        currateUrl?.queryItems?.append(apiKey)
        
        guard let url = currateUrl?.url else {
            fatalError("Error creating currate.ru url from components")
        }
        
        let urlRequest = URLRequest(url: url)
        
        return urlRequest
    }
}
