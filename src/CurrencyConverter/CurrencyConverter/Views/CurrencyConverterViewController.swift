
import UIKit
import SnapKit

final class CurrencyConverterViewController : UIViewController {
    
    private lazy var swapCurrencyButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ExchangeIcon"), for: .normal)
        return button
    }()
    
    private lazy var currencyAButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Currency", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.854, green: 0.854, blue: 0.854, alpha: 1).cgColor
        
        button.addTarget(self, action: #selector(currencyAButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var currencyATextField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .center
        textField.text = "100"
        textField.font = UIFont.systemFont(ofSize: 22)
        textField.keyboardType = .numberPad
        
        return textField
    }()
    
    private lazy var currencyAUnderline: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(red: 0.231, green: 0.44, blue: 0.977, alpha: 1)
        return line
    }()
    
    private lazy var currencyBTextField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .center
        textField.text = "0.00"
        textField.font = UIFont.systemFont(ofSize: 22)
        textField.keyboardType = .numberPad
        
        return textField
    }()
    
    private lazy var currencyBUnderline: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(red: 0.231, green: 0.44, blue: 0.977, alpha: 1)
        return line
    }()
    
    private lazy var currencyBButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Currency", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.854, green: 0.854, blue: 0.854, alpha: 1).cgColor
        
        button.addTarget(self, action: #selector(currencyBButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var refreshButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 8
        button.setTitle("Refresh", for: .normal)
        button.backgroundColor = UIColor(red: 0.231, green: 0.44, blue: 0.977, alpha: 1)
        return button
    }()
    
    private let currencyConverterViewModel: CurrencyConverterViewModel
    
    init(currencyConverterViewModel: CurrencyConverterViewModel) {
        self.currencyConverterViewModel = currencyConverterViewModel

        super.init(nibName: nil, bundle: nil)
        
        self.currencyConverterViewModel.currencyASelectedAction = currencyASelectedAction(currency:)
        self.currencyConverterViewModel.currencyBSelectedAction = currencyBSelectedAction(currency:)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
       setupUI()
    }
    
    @objc
    private func currencyAButtonPressed() {
        let currencySelectorViewModel = CurrencySelectorViewModel(currencyApi: CurrencyApi.shared)
        currencySelectorViewModel.currencySelectedAction = currencyASelectedBySelector(currency:)
        let currencySelectorController = CurrencySelectorViewController(for: "", currencySelectorViewModel: currencySelectorViewModel)
        self.navigationController?.pushViewController(currencySelectorController, animated: true)
    }
    
    @objc
    private func currencyBButtonPressed() {
        let currencySelectorViewModel = CurrencySelectorViewModel(currencyApi: CurrencyApi.shared)
        currencySelectorViewModel.currencySelectedAction = currencyBSelectedBySelector(currency:)
        let currencySelectorController = CurrencySelectorViewController(
            for: currencyConverterViewModel.currencyA,
            currencySelectorViewModel: currencySelectorViewModel)
        self.navigationController?.pushViewController(currencySelectorController, animated: true)
    }
    
    private func currencyASelectedBySelector(currency: String) {
        currencyConverterViewModel.currencyA = currency
    }
    
    private func currencyBSelectedBySelector(currency: String) {
        currencyConverterViewModel.currencyB = currency
    }
    
    private func currencyASelectedAction(currency: String) {
        currencyAButton.setTitle(currencyConverterViewModel.currencyA, for: .normal)
        currencyAButton.setTitleColor(.black, for: .normal)
    }
    
    private func currencyBSelectedAction(currency: String) {
        currencyBButton.setTitle(currencyConverterViewModel.currencyB, for: .normal)
        currencyBButton.setTitleColor(.black, for: .normal)
    }
    
    private func setupUI(){
        view.backgroundColor = .white
        
        title = "Currency converter"
        self.simplifyNavigationBar()
        
        view.addSubview(swapCurrencyButton)
        swapCurrencyButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            make.width.equalTo(18)
            make.height.equalTo(18)
        }
        
        view.addSubview(currencyAButton)
        currencyAButton.snp.makeConstraints { make in
            make.left.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.right.equalTo(swapCurrencyButton.snp.left).offset(-16)
            make.height.equalTo(56)
        }
        
        view.addSubview(currencyATextField)
        currencyATextField.snp.makeConstraints { make in
            make.left.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.top.equalTo(currencyAButton.snp.bottom).offset(16)
            make.right.equalTo(swapCurrencyButton.snp.left).offset(-16)
            make.height.equalTo(56)
        }
        
        view.addSubview(currencyAUnderline)
        currencyAUnderline.snp.makeConstraints { make in
            make.left.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.top.equalTo(currencyATextField.snp.bottom).offset(1)
            make.right.equalTo(swapCurrencyButton.snp.left).offset(-16)
            make.height.equalTo(1)
        }
        
        view.addSubview(currencyBButton)
        currencyBButton.snp.makeConstraints { make in
            make.left.equalTo(swapCurrencyButton.snp.right).offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(56)
        }
        
        view.addSubview(currencyBTextField)
        currencyBTextField.snp.makeConstraints { make in
            make.left.equalTo(swapCurrencyButton.snp.right).offset(16)
            make.top.equalTo(currencyBButton.snp.bottom).offset(16)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(56)
        }
        
        view.addSubview(currencyBUnderline)
        currencyBUnderline.snp.makeConstraints { make in
            make.left.equalTo(swapCurrencyButton.snp.right).offset(16)
            make.top.equalTo(currencyBTextField.snp.bottom).offset(1)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(1)
        }

        view.addSubview(refreshButton)
        refreshButton.snp.makeConstraints { make in
            make.left.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            make.height.equalTo(56)
        }
    }
}
