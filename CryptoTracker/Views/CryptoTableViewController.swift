import UIKit
import LocalAuthentication

class CryptoTableViewController: UITableViewController {
    
    private let headerHeight: CGFloat = 100
    private let netWorthHeight: CGFloat = 45
    
    var amountLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoinData.shared.getPrices()
        
        setupReportButton()
        
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            updateSecureButton()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CoinData.shared.delegate = self
        displayNetWorth()
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoinData.shared.coins.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let coin = CoinData.shared.coins[indexPath.row]
        
        if coin.amount != 0 {
            cell.textLabel?.text = "\(coin.symbol) - \(coin.priceAsString()) - \(coin.amount) owned"
        }
        cell.textLabel?.text = "\(coin.symbol) - \(coin.priceAsString())"
        cell.imageView?.image = coin.image
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coinVC = CoinViewController()
        coinVC.coin = CoinData.shared.coins[indexPath.row]
        navigationController?.pushViewController(coinVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createHeaderView()
    }
}

extension CryptoTableViewController {
    private func createHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: headerHeight))
        headerView.backgroundColor = .white
        
        let netWorthLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: netWorthHeight))
        netWorthLabel.textAlignment = .center
        netWorthLabel.text = "My Crypto Net Worth"
        headerView.addSubview(netWorthLabel)
        
        amountLabel.textAlignment = .center
        amountLabel.font = UIFont.boldSystemFont(ofSize: 36.0)
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(amountLabel)
        
        NSLayoutConstraint.activate([
            amountLabel.topAnchor.constraint(equalTo: netWorthLabel.bottomAnchor),
            amountLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            amountLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            amountLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
            ])
        
        return headerView
    }
    
    private func setupReportButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Report", style: .plain, target: self, action: #selector(reportTapped))
    }
    
    @objc private func reportTapped() {
        let formatter = UIMarkupTextPrintFormatter(markupText: CoinData.shared.html())
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(formatter, startingAtPageAt: 0)
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        for i in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPage()
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()
        
        let shareVC = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
        present(shareVC, animated: true, completion: nil)
    }
    
    private func displayNetWorth() {
        amountLabel.text = CoinData.shared.netWorthAsString()
    }
    
    private func updateSecureButton() {
        let buttonTitle = UserDefaults.standard.bool(forKey: "secure") ? "Unsecure App" : "Secure App"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: buttonTitle, style: .plain, target: self, action: #selector(secureTapped))
    }
    
    @objc private func secureTapped() {
        let updatedBool = !UserDefaults.standard.bool(forKey: "secure")
        UserDefaults.standard.set(updatedBool, forKey: "secure")
        updateSecureButton()
    }
}

extension CryptoTableViewController: CoinDataDelegate {
    func newPrices() {
        displayNetWorth()
        tableView.reloadData()
    }
}
