
import UIKit
import SnapKit

final class CurrencyConverterViewController : UIViewController {
    
    private lazy var swapCurrencyButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ExchangeIcon"), for: .normal)
        
        button.addTarget(self, action: #selector(swapCurrencyButtonPressed), for: .touchUpInside)
        
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
        textField.font = UIFont.systemFont(ofSize: 22)
        textField.keyboardType = .numberPad
        
        textField.delegate = self
        
        textField.addTarget(self, action: #selector(currencyATextFieldEditingChanged), for: .editingChanged)
        
        return textField
    }()
    
    private lazy var currencyAUnderline: UIView = {
        let line = UIView()
        line.backgroundColor = Colors.textEditBorder
        return line
    }()
    
    private lazy var currencyBTextField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 22)
        textField.keyboardType = .numberPad
        
        return textField
    }()
    
    private lazy var currencyBUnderline: UIView = {
        let line = UIView()
        line.backgroundColor = Colors.textEditBorder
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
        button.setTitleColor(.lightGray, for: .disabled)
        button.backgroundColor = UIColor(red: 0.231, green: 0.44, blue: 0.977, alpha: 1)
        
        button.addTarget(self, action: #selector(performCalculation), for: .touchUpInside)
        
        return button
    }()
    
    private var refreshButtonBottomConstraint: NSLayoutConstraint! = nil
    
    private let converterViewModel: CurrencyConverterViewModel
    
    init(currencyConverterViewModel: CurrencyConverterViewModel) {
        self.converterViewModel = currencyConverterViewModel

        super.init(nibName: nil, bundle: nil)
        
        self.converterViewModel.currencyASelectedAction = currencyASelectedAction(currency:)
        self.converterViewModel.currencyBSelectedAction = currencyBSelectedAction(currency:)
        self.converterViewModel.currencyBValueChangedAction = currencyBValueChangedAction(amount:)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
       setupUI()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    @objc
    private func swapCurrencyButtonPressed() {
        converterViewModel.swap()
    }
    
    @objc
    private func currencyAButtonPressed() {
        let currencySelectorViewModel = CurrencySelectorViewModel(
            currencyApi: CurrencyApi.shared,
            selectedCurrency: converterViewModel.currencyA)
        currencySelectorViewModel.currencySelectedAction = currencyASelectedBySelector(currency:)
        let currencySelectorController = CurrencySelectorViewController(for: "", currencySelectorViewModel: currencySelectorViewModel)
        self.navigationController?.pushViewController(currencySelectorController, animated: true)
    }
    
    @objc
    private func currencyBButtonPressed() {
        let currencySelectorViewModel = CurrencySelectorViewModel(
            currencyApi: CurrencyApi.shared,
            selectedCurrency: converterViewModel.currencyB,
            exceptCurrency: converterViewModel.currencyA)
        currencySelectorViewModel.currencySelectedAction = currencyBSelectedBySelector(currency:)
        let currencySelectorController = CurrencySelectorViewController(
            for: converterViewModel.currencyA,
            currencySelectorViewModel: currencySelectorViewModel)
        self.navigationController?.pushViewController(currencySelectorController, animated: true)
    }
    
    @objc
    private func currencyATextFieldEditingChanged() {
        guard let text = currencyATextField.text else {return}
        guard let currencyParsedValue = Double(text) else {return}
        converterViewModel.currencyAValue = Double(currencyParsedValue)
        refreshButton.isEnabled = converterViewModel.isCalculationEnabled
    }
    
    @objc
    private func currencyATextFieldTouch() {
        guard let text = currencyATextField.text else {return}
        guard let currencyParsedValue = Double(text) else {return}
        converterViewModel.currencyAValue = Double(currencyParsedValue)
        refreshButton.isEnabled = converterViewModel.isCalculationEnabled
    }
    
    @objc
    private func performCalculation() {
        converterViewModel.calculate()
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification, keyboardWillShow: true)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification, keyboardWillShow: false)
    }
    
    func moveViewWithKeyboard(notification: NSNotification, keyboardWillShow: Bool) {
        // Keyboard's size
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardSize.height
        
        // Keyboard's animation duration
        let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        // Keyboard's animation curve
        let keyboardCurve = UIView.AnimationCurve(rawValue: notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!
        
        // Change the constant
        if keyboardWillShow {
            let safeAreaExists = (self.view?.window?.safeAreaInsets.bottom != 0) // Check if safe area exists
            let bottomConstant: CGFloat = 5
            refreshButtonBottomConstraint.constant = -(keyboardHeight + (safeAreaExists ? 0 : bottomConstant))
        } else {
            refreshButtonBottomConstraint.constant = -24
        }
        
        // Animate the view the same way the keyboard animates
        let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
            // Update Constraints
            self?.view.layoutIfNeeded()
        }
        
        // Perform the animation
        animator.startAnimation()
    }
    
    private func currencyASelectedBySelector(currency: String) {
        converterViewModel.currencyA = currency
        swapCurrencyButton.isEnabled = converterViewModel.isSwapEnabled
    }
    
    private func currencyBSelectedBySelector(currency: String) {
        converterViewModel.currencyB = currency
        swapCurrencyButton.isEnabled = converterViewModel.isSwapEnabled
    }
    
    private func currencyASelectedAction(currency: String) {
        currencyAButton.setTitle(converterViewModel.currencyA, for: .normal)
        currencyAButton.setTitleColor(.black, for: .normal)
        refreshButton.isEnabled = converterViewModel.isCalculationEnabled
    }
    
    private func currencyBSelectedAction(currency: String) {
        currencyBButton.setTitle(converterViewModel.currencyB, for: .normal)
        currencyBButton.setTitleColor(.black, for: .normal)
        refreshButton.isEnabled = converterViewModel.isCalculationEnabled
    }
    
    private func currencyBValueChangedAction(amount: Double) {
        currencyBTextField.text = String(format: "%.2f", amount)
    }
    
    private func setupUI(){
        view.backgroundColor = .white
        
        title = "Currency converter"
        self.simplifyNavigationBar()
        
        refreshButton.isEnabled = converterViewModel.isCalculationEnabled
        swapCurrencyButton.isEnabled = converterViewModel.isSwapEnabled
        
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
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
//        refreshButton.snp.makeConstraints { make in
//            make.left.equalTo(view.safeAreaLayoutGuide).offset(24)
//            make.right.equalTo(view.safeAreaLayoutGuide).offset(-24)
//            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
//            make.height.equalTo(56)
//        }
        
        self.refreshButtonBottomConstraint = refreshButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        NSLayoutConstraint.activate([
            refreshButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 24),
            refreshButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -24),
            self.refreshButtonBottomConstraint,
            refreshButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
}

extension CurrencyConverterViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.currencyAUnderline.backgroundColor = Colors.textEditBorderActive
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.currencyAUnderline.backgroundColor = Colors.textEditBorder
    }
}
