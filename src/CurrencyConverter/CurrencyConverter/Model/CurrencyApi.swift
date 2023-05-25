
import Foundation

enum ApiErrors : String, Error {
    case dataIsNil = "Data is nil!"
    case jsonParseError = "JSON parse error"
}

final class CurrencyApi : CurrencyApiProtocol {
    
    private let currencyList = URLQueryItem(name: "get", value: "currency_list")
    private let currencyRate = URLQueryItem(name: "get", value: "rates")
    private let apiKey = URLQueryItem(name: "key", value: "2a40531fd76d6dad9b120312b752c827")
    
    static var shared: CurrencyApiProtocol = CurrencyApi()
    
    private init(){
        
    }
    
    func performCurrencyListRequest(completion: @escaping (Result<CurrencyListReponse, Error>) -> Void) {
        var currateUrl = URLComponents(string: "https://currate.ru/api/?")
        currateUrl?.queryItems?.append(currencyList)
        currateUrl?.queryItems?.append(apiKey)
        
        guard let url = currateUrl?.url else {
            fatalError("Error creating currate.ru url from components")
        }
        
        let request = URLRequest(url: url)
        
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
    
    func performCurrencyRateRequest(pair: String, completion: @escaping (Result<CurrencyRate, Error>) -> Void) {
        var currateUrl = URLComponents(string: "https://currate.ru/api/?")
        currateUrl?.queryItems?.append(currencyRate)
        currateUrl?.queryItems?.append(URLQueryItem(name: "pairs", value: pair))
        currateUrl?.queryItems?.append(apiKey)
        
        print(currateUrl?.url)
        
        guard let url = currateUrl?.url else {
            fatalError("Error creating currate.ru url from components")
        }
        
        let request = URLRequest(url: url)
        
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
                let currencyRatesResponse = try decoder.decode(CurrencyRatesResponse.self, from: data)
                let firstKeyValuePair = currencyRatesResponse.data.first!
                let currencyRate = CurrencyRate(title: firstKeyValuePair.key, value: Double(firstKeyValuePair.value)!)
                completion(.success(currencyRate))
            }
            catch {
                print(error)
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
