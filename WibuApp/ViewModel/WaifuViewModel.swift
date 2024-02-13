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
    @Published var imageToShare: UIImage?
    @Published var shouldShowBottomsheet: Bool = false
    
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
    
    func deleteWaifu(id: UUID) {
        guard let targetWaifu = waifus.firstIndex(where: { waifu in
            waifu.id == id
        }) else {
            print("no waifu found")
            
            return
        }
        
        waifus.remove(at: targetWaifu)
    }
    
    // download Image
    func downloadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            return UIImage(data: data)
        } catch {
            print("Error downloading image: \(error)")
            
            return nil
        }
    }
    
    // prepare image
    func prepareImageAndShowsheet(from urlString: String) async {
        imageToShare = await downloadImage(from: urlString)
        shouldShowBottomsheet = true
    }
}
