import UIKit
import LocalAuthentication

class AuthViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        presentAuth()
    }
    
    private func presentAuth() {
        let authMessage = "Your crypto-currency information is protected with biometrics"
        LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: authMessage) { (success, error) in
            if success {
                DispatchQueue.main.async {
                    let cryptoTableVC = CryptoTableViewController()
                    let navController = UINavigationController(rootViewController: cryptoTableVC)
                    self.present(navController, animated: true, completion: nil)
                }
            } else {
                self.presentAuth()
            }
        }
    }
}
