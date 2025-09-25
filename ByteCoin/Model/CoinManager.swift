import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(_ coinManager: CoinManager, coinData: CoinModel)
    func didFailWithError(_ error: Error)
}

struct CoinManager {
    let baseURL: String
    let apiKey: String
    var delegate: CoinManagerDelegate?
    let currencyArray = [
        "USD", "AUD", "BRL", "CAD", "EUR", "GBP", "HKD", "ILS", "INR",
        "JPY", "MXN", "NOK", "NZD", "PLN", "RON", "RUB", "SEK", "SGD",
        "ZAR",
    ]

    init() {
        let key =
            Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String ?? ""
        apiKey = key
        baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC/"
    }

    func getCoinPrice(for currency: String) async throws {
        let urlString = "\(baseURL)\(currency)?apiKey=\(apiKey)"
        try await fetchCoinData(with: urlString)
    }

    func fetchCoinData(with urlString: String) async throws {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let result = try decoder.decode(CoinData.self, from: data)
            let coinData = CoinModel(price: result.rate, symbol: result.asset_id_base, currency: result.asset_id_quote)
            delegate?.didUpdatePrice(self, coinData: coinData)
        } catch {
            self.delegate?.didFailWithError(error)
        }
    }

}
