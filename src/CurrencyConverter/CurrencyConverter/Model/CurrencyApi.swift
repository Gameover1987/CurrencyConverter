
import Foundation

enum ApiErrors : String, Error {
    case dataIsNil = "Data is nil!"
    case jsonParseError = "JSON parse error"
}

final class CurrencyApi : CurrencyApiProtocol {
    
    // Время жизни значений в кеше, решил поставить 1 час
    private let cacheLifeTimeInSeconds = Double(1 * 60 * 60)
    
    private let currencyList = URLQueryItem(name: "get", value: "currency_list")
    private let currencyRate = URLQueryItem(name: "get", value: "rates")
    private let apiKey = URLQueryItem(name: "key", value: "2a40531fd76d6dad9b120312b752c827")
    
    static var shared: CurrencyApiProtocol = CurrencyApi()
    
    private var pairsCache: [CurrencyPair] = []
    private var lastCurrencyListResponse: CurrencyListReponse?
    private var lastCurrencyListRequested: Date = Date()
    
    private init() {
        
    }
    
    func performCurrencyListRequest(completion: @escaping (Result<CurrencyListReponse, Error>) -> Void) {
        
        if (lastCurrencyListResponse != nil &&
            lastCurrencyListRequested.addingTimeInterval(cacheLifeTimeInSeconds) > Date()) {
            completion(.success(lastCurrencyListResponse!))
            return
        }
        
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
                self.lastCurrencyListResponse = try decoder.decode(CurrencyListReponse.self, from: data)
                self.lastCurrencyListRequested = Date()
                completion(.success(self.lastCurrencyListResponse!))
            }
            catch {
                print(error)
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func performCurrencyRateRequest(pairAsString: String, completion: @escaping (Result<CurrencyRate, Error>) -> Void) {
        
        let pair = getFromCache(pairAsString)
        if (pair != nil) {
            let currencyRate = CurrencyRate(title: pairAsString, value: Double(pair!.value))
            completion(.success(currencyRate))
            return
        }
        
        var currateUrl = URLComponents(string: "https://currate.ru/api/?")
        currateUrl?.queryItems?.append(currencyRate)
        currateUrl?.queryItems?.append(URLQueryItem(name: "pairs", value: pairAsString))
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
                let currencyRatesResponse = try decoder.decode(CurrencyRatesResponse.self, from: data)
                let firstKeyValuePair = currencyRatesResponse.data.first!
                let currencyRate = CurrencyRate(title: firstKeyValuePair.key, value: Double(firstKeyValuePair.value)!)
                
                let pair = CurrencyPair(pairAsString, value: currencyRate.value)
                self.pairsCache.append(pair)
                
                completion(.success(currencyRate))
            }
            catch {
                print(error)
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    private func getFromCache(_ pairAsString: String) -> CurrencyPair? {
        
        pairsCache.removeAll { pair in
            return pair.created.addingTimeInterval(cacheLifeTimeInSeconds) < Date()
        }
        
        let pair = CurrencyPair(pairAsString)
        
        for pairInCache in pairsCache {
            if (pairInCache.equals(other: pair)) {
                return pairInCache.getSelfOrInverted(other: pair)
            }
        }
        
        return nil
    }
}
