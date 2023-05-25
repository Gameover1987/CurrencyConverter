
import UIKit
import SnapKit

final class CurrencySelectorViewController : UIViewController {
    
    private let cellIdentifier = UUID().uuidString
    
    private var currency: String
    private let currencySelectorViewModel: CurrencySelectorViewModel
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView;
    }()
    
    init(for currency: String, currencySelectorViewModel: CurrencySelectorViewModel) {
        self.currency = currency
        self.currencySelectorViewModel = currencySelectorViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        title = "Select currency"
        
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currencySelectorViewModel.fetch(for: currency) { [weak self] result in
            
            guard let self = self else {return}
            
            switch result {
            case .failure(let error):
                print(error)
                
            case .success(_):
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension CurrencySelectorViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currency = currencySelectorViewModel.currencyList[indexPath.row]
        currencySelectorViewModel.selectedCurrency = currency
        self.navigationController?.popViewController(animated: true)
    }
}

extension CurrencySelectorViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencySelectorViewModel.currencyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = currencySelectorViewModel.currencyList[indexPath.row]
        return cell
    }
}
