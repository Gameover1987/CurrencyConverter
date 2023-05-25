
import Foundation

struct CurrencyListReponse : Codable {
    var status: String
    
    var message: String
    
    var data: [String]
}

struct CurrencyRatesResponse : Codable {
    var status: Int
    
    var message: String
    
    var data: [CurrencyCalculation]
}

struct CurrencyCalculation : Codable {
    var name: String
    
    var value: Double
}
