//
//  Result.swift
//  LivesportSearch
//
//  Created by Jan Tomeš on 14.02.2023.
//

import Foundation
import SwiftUI

struct Result: Codable, Identifiable {
    let id: String
    let name: String
    let sport: Sport
    let defaultCountry: Country
    let images: [Img]

    struct Sport: Codable {
        let name: String
    }

    struct Country: Codable {
        let name: String
    }

    struct Img: Codable {
        let path: String?
    }

    var smallImage: some View {
        Group {
            if let path = images.first?.path {
                AsyncImage(url: URL(string: "https://www.livesport.cz/res/image/data/" + path)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                } placeholder: {
                    Image(systemName: "person")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .opacity(0.5)
                }
            } else {
                Image(systemName: "person")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .opacity(0.5)
            }
        }
    }
}
