//
//  ContentView.swift
//  WibuApp
//
//  Created by Pande Adhistanaya on 12/02/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var waifuVM = WaifuViewModel()
    
    let columns: Array<GridItem> = [
        GridItem(.adaptive(minimum: 100), spacing: 10)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(waifuVM.waifus) { waifu in
                    Group {
                        let imageUrl = URL(string: waifu.image)
                        
                        AsyncImage(url: imageUrl) { fetchedWaifu in
                            switch fetchedWaifu {
                            case .empty:
                                waitView()
                                 
                            case .success(let image):
                                image.resizable().scaledToFill()
                                
                            case .failure(let error):
                                VStack {
                                    Image(systemName: "photo.fill")
                                    Text(error.localizedDescription)
                                }
                                
                            @unknown default:
                                fatalError()
                            }
                        }
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .task {
            await waifuVM.fetchWaifus()
        }
    }
}

#Preview {
    ContentView()
}

@ViewBuilder
func waitView() -> some View {
    VStack {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(.blue)
        
        Text("fetching image...")
    }
}
