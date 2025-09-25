import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, CoinManagerDelegate {

    @IBOutlet weak var bitcoinLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
    
    var coinManager = CoinManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
        coinManager.delegate = self
        
        Task {
            do {
                try await coinManager.getCoinPrice(for: coinManager.currencyArray[0])
            } catch {
                didFailWithError(error)
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        coinManager.currencyArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return coinManager.currencyArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedCurrency = coinManager.currencyArray[row]
        Task {
            try await coinManager.getCoinPrice(for: selectedCurrency)
        }
    }
    
    func didUpdatePrice(_ coinManager: CoinManager, coinData: CoinModel) {
        DispatchQueue.main.async {
            self.currencyLabel.text = coinData.currency
            self.bitcoinLabel.text = NumberFormatter.localizedString(
                from: NSNumber(value: Int(coinData.price)),
                number: .decimal
            )
        }
    }
    
    func didFailWithError(_ error: Error) {
        print(error)
    }
}

