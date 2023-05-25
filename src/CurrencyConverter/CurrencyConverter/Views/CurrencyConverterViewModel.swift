
import Foundation

final class CurrencyConverterViewModel {
    
    private var currencyApi: CurrencyApiProtocol
    
    init(currencyApi: CurrencyApiProtocol) {
        self.currencyApi = currencyApi
    }
    
    var currencyA: String = "" {
        didSet {
            currencyASelectedAction?(currencyA)
        }
    }
    
    var currencyASelectedAction: ((String) -> Void)?
    
    var currencyB: String = "" {
        didSet {
            currencyBSelectedAction?(currencyB)
        }
    }
    
    var currencyBSelectedAction: ((String) -> Void)?
    
    func calculate(completion: @escaping (Double) -> Void) {
        
    }
}
