
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
    
    var currencyAValue: Double = 0.0 {
        didSet {
            currencyAValueChangedAction?(currencyAValue)
        }
    }
    
    var currencyAValueChangedAction: ((Double) -> Void)?
    
    var currencyB: String = "" {
        didSet {
            currencyBSelectedAction?(currencyB)
        }
    }
    
    var currencyBSelectedAction: ((String) -> Void)?
    
    var currencyBValue: Double = 0.0 {
        didSet {
            currencyBValueChangedAction?(currencyBValue)
        }
    }
    
    var currencyBValueChangedAction: ((Double) -> Void)?
    
    var isCalculationEnabled: Bool {
        
        if (currencyA.isEmpty || currencyB.isEmpty) {
            return false
        }
        
        if (currencyAValue <= 0) {
            return false
        }
        
        return true
    }
    
    var isSwapEnabled: Bool {
        if (currencyA.isEmpty || currencyB.isEmpty) {
            return false
        }
        
        return true
    }
    
    func swap() {
        let buffer = currencyA
        currencyA = currencyB
        currencyB = buffer
    }
    
    func calculate() {
        let pair = currencyA+currencyB
        currencyApi.performCurrencyRateRequest(pairAsString: pair) { [weak self] result in
            guard let self = self else {return}
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let rate):
                DispatchQueue.main.async {
                    self.currencyBValue = self.currencyAValue * rate.value
                }
            }
        }
    }
}
