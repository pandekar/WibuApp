//
//  ContentView.swift
//  WibuApp
//
//  Created by Pande Adhistanaya on 12/02/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var waifuVM = WaifuViewModel()
    @State private var searchText: String = ""
    @State private var isDeleteAlertPresented = false
    @State private var selectedDeleteWaifu: Waifu?

    var filteredWaifus: Array<Waifu> {
        if searchText.isEmpty {
            return waifuVM.waifus
        } else {
            return waifuVM.waifus.filter { waifu in
                waifu.name.contains(searchText)
            }
        }
    }
    
    let columns: Array<GridItem> = [
        GridItem(.adaptive(minimum: 100), spacing: 10)
    ]
    let transition = Transaction(animation: .easeInOut(duration: 3.0))
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(filteredWaifus) { waifu in
                        Group {
                            let imageUrl = URL(string: waifu.image)
                            VStack(alignment: .leading) {
                                AsyncImage(url: imageUrl, transaction: transition) { fetchedWaifu in
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
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                Text(waifu.name)
                                    .bold()
                                Spacer()
                                Text(waifu.anime)
                                    .lineLimit(1)
                            }
                        }
                        .padding()
                        .contextMenu(ContextMenu(menuItems: {
                            Button {
                                Task {
                                    await waifuVM.prepareImageAndShowsheet(from: waifu.image)
                                }
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            Button {
                                selectedDeleteWaifu = waifu
                                isDeleteAlertPresented.toggle()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }))
                        .sheet(isPresented: $waifuVM.shouldShowBottomsheet, content: {
                            Group {
                                let defaultText = "You are about to share this items"
                                
                                if let imageToShare = waifuVM.imageToShare {
                                    ActivityView(activityItem: [defaultText, imageToShare])
                                } else {
                                    ActivityView(activityItem: [defaultText])
                                }
                            }
                            // ukuran bottomsheet
                            .presentationDetents([.medium, .large])
                        })
                    }
                }
            }
            .task {
                await waifuVM.fetchWaifus()
            }
            .refreshable(action: {
                await waifuVM.fetchWaifus()
            })
            .navigationTitle("Wibu")
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "e.g Ikuyo Kita"
            )
            .autocorrectionDisabled(true)
            .overlay {
                if filteredWaifus.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
        }
        .alert(isPresented: $isDeleteAlertPresented) {
            // show alert before delete
            Alert(
                title: Text("Delete Waifu"),
                message: Text("Are you sure you want to delete waifu \(selectedDeleteWaifu?.name ?? "")?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let waifu = selectedDeleteWaifu {
                        waifuVM.deleteWaifu(id: waifu.id)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
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

#Preview {
    ContentView()
}
