import UIKit
import SwiftChart

private let chartHeight: CGFloat = 300.0
private let imageSize: CGFloat = 100.0
private let priceLabelHeight: CGFloat = 25.0

class CoinViewController: UIViewController {
    
    var chart = Chart()
    var coin: Coin?
    var priceLabel = UILabel()
    var quantityOwnedLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoinData.shared.delegate = self
        edgesForExtendedLayout = []
        view.backgroundColor = .white
        
        guard let coin = coin else { return }
        
        chart.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: chartHeight)
        
        chart.xLabels = [30, 25, 20, 15, 10, 5, 0]
        
        chart.xLabelsFormatter = { String(Int(round(30 - $1))) + "d"}
        
        chart.yLabelsFormatter = {
            CoinData.shared.doubleToMoneyString($1)
        }
        view.addSubview(chart)
        
        let imageView = UIImageView(frame: CGRect(x: view.frame.size.width / 2 - imageSize / 2, y: chartHeight + 20, width: imageSize, height: imageSize))
        imageView.image = coin.image
        view.addSubview(imageView)
        
        priceLabel.frame = CGRect(x: 0, y: chartHeight + imageSize + 30, width: view.frame.size.width, height: priceLabelHeight)
        priceLabel.textAlignment = .center
        priceLabel.text = coin.priceAsString()
        view.addSubview(priceLabel)
        
        quantityOwnedLabel.frame = CGRect(x: 0, y: chartHeight + imageSize + priceLabelHeight * 2 + 10, width: view.frame.size.width, height: priceLabelHeight)
        quantityOwnedLabel.textAlignment = .center
        quantityOwnedLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        quantityOwnedLabel.text = "Owned: \(coin.amount) \(coin.symbol)"
        view.addSubview(quantityOwnedLabel)
        
        coin.getHistoricalData()
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
        priceLabel.text = coin?.priceAsString()
    }
}
