
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow()
        self.window = window
        
        let currencyConverterViewModel = CurrencyConverterViewModel(currencyApi: CurrencyApi.shared)
        let mainViewController = CurrencyConverterViewController(currencyConverterViewModel: currencyConverterViewModel)
        let navigationController = UINavigationController(rootViewController: mainViewController)
        
        window.rootViewController = navigationController
        if #available(iOS 13, *) {
            window.overrideUserInterfaceStyle = .light
        }
        
        window.makeKeyAndVisible()
        
        return true
    }
    
}

