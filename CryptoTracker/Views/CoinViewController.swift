import UIKit
import SwiftChart

private let chartHeight: CGFloat = 300.0

class CoinViewController: UIViewController {
    
    var chart = Chart()
    var coin: Coin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoinData.shared.delegate = self
        
        view.backgroundColor = .white
        
        chart.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: chartHeight)
        view.addSubview(chart)
        
        coin?.getHistoricalData()
    }
}

extension CoinViewController: CoinDataDelegate {
    func newHistory() {
        guard let coin = coin else { return }
        
        let series = ChartSeries(coin.historicalData)
        series.area = true
        chart.add(series)
    }
}
