import UIKit

class CryptoTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoinData.shared.delegate = self
        
        CoinData.shared.getPrices()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoinData.shared.coins.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let coin = CoinData.shared.coins[indexPath.row]
        
        cell.textLabel?.text = "\(coin.symbol) - \(coin.priceAsString())"
        cell.imageView?.image = coin.image
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coinVC = CoinViewController()
        coinVC.coin = CoinData.shared.coins[indexPath.row]
        navigationController?.pushViewController(coinVC, animated: true)
    }
}

extension CryptoTableViewController: CoinDataDelegate {
    func newPrices() {
        tableView.reloadData()
    }
}
