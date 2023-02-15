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

    var image: some View {
        Group {
            if let path = images.first?.path {
                AsyncImage(url: URL(string: "https://www.livesport.cz/res/image/data/" + path)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Image(systemName: "person")
                        .resizable()
                        .scaledToFit()
                        .opacity(0.5)
                }
            } else {
                Image(systemName: "person")
                    .resizable()
                    .scaledToFit()
                    .opacity(0.5)
            }
        }
    }

    static let example = Result(
        id: "AZg49Et9",
        name: "Djokovic Novak",
        sport: Sport(name: "Tennis"),
        defaultCountry: Country(name: "Serbia"),
        images: [Img]()
    )
}
