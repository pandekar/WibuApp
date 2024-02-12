//
//  Waifu.swift
//  WibuApp
//
//  Created by Pande Adhistanaya on 12/02/24.
//

import Foundation

struct Waifu: Decodable, Identifiable {
    var id = UUID()
    let image: String
    let anime: String
    let name: String
}
