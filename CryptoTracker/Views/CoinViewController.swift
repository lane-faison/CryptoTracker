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
        
        guard let coin = coin else { return }
        
        setupChart()
        setupImageView(coin: coin)
        setupPriceLabel(coin: coin)
        setupQuantityOwnedLabel(coin: coin)
        setupTotalValueLabel(coin: coin)
        
        coin.getHistoricalData()
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
    
    private func setupImageView(coin: Coin) {
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: chart.bottomAnchor, constant: 20.0),
            imageView.centerXAnchor.constraint(equalTo: chart.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: view.frame.size.height / 6),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
            ])
        imageView.image = coin.image
    }
    
    private func setupPriceLabel(coin: Coin) {
        view.addSubview(priceLabel)
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5.0),
            priceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            priceLabel.heightAnchor.constraint(equalToConstant: 25.0)
            ])
        priceLabel.text = coin.priceAsString()
    }
    
    private func setupQuantityOwnedLabel(coin: Coin) {
        view.addSubview(quantityOwnedLabel)
        NSLayoutConstraint.activate([
            quantityOwnedLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 20.0),
            quantityOwnedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            quantityOwnedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            quantityOwnedLabel.heightAnchor.constraint(equalToConstant: 25.0)
            ])
        quantityOwnedLabel.text = "Owned: \(coin.amount) \(coin.symbol)"
    }
    
    private func setupTotalValueLabel(coin: Coin) {
        view.addSubview(totalValueLabel)
        NSLayoutConstraint.activate([
            totalValueLabel.topAnchor.constraint(equalTo: quantityOwnedLabel.bottomAnchor, constant: 10.0),
            totalValueLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            totalValueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            totalValueLabel.heightAnchor.constraint(equalToConstant: 25.0)
            ])
        totalValueLabel.text = "Value: \(coin.valueAsString())"
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
