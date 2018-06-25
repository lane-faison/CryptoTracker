import UIKit
import SwiftChart

class CoinViewController: UIViewController {
    
    var coin: Coin?
    
    var chart: Chart = {
        let chart = Chart()
        chart.translatesAutoresizingMaskIntoConstraints = false
        return chart
    }()
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var quantityOwnedLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        return label
    }()
    
    var totalValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoinData.shared.delegate = self
        edgesForExtendedLayout = []
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
        
        guard let coin = coin else { return }
        
        title = coin.symbol
        
        setupChart()
        setupImageView()
        setupPriceLabel()
        setupQuantityOwnedLabel()
        setupTotalValueLabel()
        
        coin.getHistoricalData()
        newPrices()
    }
}

// MARK: View setup functions

extension CoinViewController {
    private func setupChart() {
        view.addSubview(chart)
        NSLayoutConstraint.activate([
            chart.topAnchor.constraint(equalTo: view.topAnchor),
            chart.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chart.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chart.heightAnchor.constraint(equalToConstant: view.frame.size.height / 2.5)
            ])
        chart.xLabels = [30, 25, 20, 15, 10, 5, 0]
        chart.xLabelsFormatter = { String(Int(round(30 - $1))) + "d"}
        chart.yLabelsFormatter = {
            CoinData.shared.doubleToMoneyString($1)
        }
    }
    
    private func setupImageView() {
        guard let coin = coin else { return }
        
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: chart.bottomAnchor, constant: 20.0),
            imageView.centerXAnchor.constraint(equalTo: chart.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: view.frame.size.height / 6),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
            ])
        imageView.image = coin.image
    }
    
    private func setupPriceLabel() {
        view.addSubview(priceLabel)
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5.0),
            priceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            priceLabel.heightAnchor.constraint(equalToConstant: 25.0)
            ])
    }
    
    private func setupQuantityOwnedLabel() {
        view.addSubview(quantityOwnedLabel)
        NSLayoutConstraint.activate([
            quantityOwnedLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 20.0),
            quantityOwnedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            quantityOwnedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            quantityOwnedLabel.heightAnchor.constraint(equalToConstant: 25.0)
            ])
    }
    
    private func setupTotalValueLabel() {
        view.addSubview(totalValueLabel)
        NSLayoutConstraint.activate([
            totalValueLabel.topAnchor.constraint(equalTo: quantityOwnedLabel.bottomAnchor, constant: 10.0),
            totalValueLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            totalValueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            totalValueLabel.heightAnchor.constraint(equalToConstant: 25.0)
            ])
    }
}

extension CoinViewController {
    @objc private func editTapped() {
        guard let coin = coin else { return }
        
        let alert = UIAlertController(title: "How much \(coin.symbol) do you own?", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "i.e. 20.00"
            textField.keyboardType = .decimalPad
            
            if self.coin?.amount != 0.0 {
                textField.text = String(coin.amount)
            }
        }
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            guard let text = alert.textFields?.first?.text else { return }
            
            if let amount = Double(text) {
                self.coin?.amount = amount
                UserDefaults.standard.set(amount, forKey: coin.symbol + "amount")
                self.newPrices()
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension CoinViewController: CoinDataDelegate {
    func newHistory() {
        guard let coin = coin else { return }
        
        let series = ChartSeries(coin.historicalData)
        series.area = true
        chart.add(series)
    }
    
    func newPrices() {
        guard let coin = coin else { return }
        
        priceLabel.text = coin.priceAsString()
        quantityOwnedLabel.text = "Owned: \(coin.amount) \(coin.symbol)"
        totalValueLabel.text = "Value: \(coin.valueAsString())"
    }
}
