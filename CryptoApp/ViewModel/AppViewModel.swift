//
//  AppViewModel.swift
//  CryptoApp
//
//  Created by MINH DUC NGUYEN on 02/07/2022.
//

import SwiftUI

class AppViewModel: ObservableObject {
    @Published var coins: [CryptoModel]?
    @Published var currentCoin: CryptoModel?
    
    init() {
        Task {
            do {
                try await fetchData()
            } catch {
                // Error
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: - Fetching Data
    func fetchData() async throws {
        //MARK: - Using latest Async/Await
        guard let url = url else { return }
        let session = URLSession.shared
        
        let response = try await session.data(from: url)
        let jsonData = try JSONDecoder().decode([CryptoModel].self, from: response.0)
        
        //MARK: - Alternative For DispathQueue Main
        await MainActor.run(body: {
            self.coins = jsonData
            if let firstCoin = jsonData.first {
                self.currentCoin = firstCoin
            }
        })
    }
}

