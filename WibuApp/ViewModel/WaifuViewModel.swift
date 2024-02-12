//
//  WaifuViewModel.swift
//  WibuApp
//
//  Created by Pande Adhistanaya on 12/02/24.
//

import Foundation
import SwiftUI

@MainActor
class WaifuViewModel: ObservableObject {
    @Published var waifus: Array<Waifu> = []
    
    func loadWaifus() async throws -> Array<Waifu> {
        // 1: Validasi URL
        guard let waifuUrl = URL(string: "https://waifu-generator.vercel.app/api/v1") else {
            throw URLError(.badURL)
        }
        
        // 2: Data
        let (data, _) = try await URLSession.shared.data(from: waifuUrl)
        
        // 3: decode data
        let waifus = try JSONDecoder().decode(Array<Waifu>.self, from: data)
        
        return waifus
    }
    
    func fetchWaifus() async {
        do {
            let loadedWaifus = try await loadWaifus()
            
            self.waifus = loadedWaifus
        } catch {
            print(error)
        }
    }
}
