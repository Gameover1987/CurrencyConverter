
import Foundation

final class CurrencyPair {

    init (_ currencyPairAsString: String) {
        self.currencyA = currencyPairAsString[0..<3]
        self.currencyB = currencyPairAsString[3...]
        
        self.created = Date()
    }
    
    convenience init (_ currencyPairAsString: String, value: Double) {
        self.init(currencyPairAsString)
        self.value = value
    }
    
    let currencyA: String
    let currencyB: String
    
    let created: Date
    
    var value: Double = 0
    
    func contains(_ currency: String) -> Bool {
        return currencyA == currency || currencyB == currency
    }
    
    func toArray() -> [String] {
        return [currencyA, currencyB]
    }
    
    func equals(other: CurrencyPair) -> Bool {
        return contains(other.currencyA) && contains(other.currencyB)
    }
    
    func getSelfOrInverted(other: CurrencyPair) -> CurrencyPair {
        if (self.currencyA == other.currencyA && self.currencyB == other.currencyB) {
            return self
        }
        
        other.value = 1 / value
        return other
    }
}
