//
//  DetailView.swift
//  LivesportSearch
//
//  Created by Jan Tomeš on 14.02.2023.
//

import SwiftUI

struct DetailView: View {
    let result: Result

    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()

                    result.image
                        .frame(width: 100, height: 100)

                    Spacer()
                }
            }

            Section {
                Text(result.sport.name)
                Text(result.defaultCountry.name)
            }
        }
        .navigationTitle(result.name)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(result: Result.example)
    }
}
