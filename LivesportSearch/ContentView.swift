//
//  ContentView.swift
//  LivesportSearch
//
//  Created by Jan Tomeš on 13.02.2023.
//

import SwiftUI

struct ContentView: View {
    enum LoadingState {
        case none, loading, loaded, failed
    }

    let entityTypes = ["Vše", "Soutěže", "Týmy"]
    
    @State private var selectedEntityType = "Vše"
    @State private var searchText = ""

    @State private var results = [Result]()
    @State private var loadingState = LoadingState.none

    @State private var showingLessThan2Chars = false
    @State private var showingFailure = false
    @State private var retrySearch = false


    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("Vyhledej si soutěž nebo tým", text: $searchText)

                        if searchText != "" {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                                .onTapGesture {
                                    searchText = ""
                                }
                        }

                        Button("Hledat") {
                            Task {
                                await search()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.leading, 5)
                    }
                }

                Section {
                    Picker("", selection: $selectedEntityType) {
                        ForEach(entityTypes, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)

                    switch loadingState {
                    case .none:
                        Text("Zde se zobrazí výsledky vyhledávání.")
                    case .loading:
                        Text("Načítáme výsledky...")
                    case .loaded:
                        if results.count > 0 {
                            ForEach(results) { result in
                                NavigationLink {
                                    DetailView(result: result)
                                } label: {
                                    HStack {
                                        result.image
                                            .frame(width: 20, height: 20)
                                        Text(result.name)
                                    }
                                }
                            }
                        } else {
                            Text("Nebyl nalezen žádný výsledek.")
                        }
                    case .failed:
                        EmptyView()
                    }
                }
            }
            .navigationTitle("Výsledky")
            .onChange(of: selectedEntityType) { _ in
                Task {
                    await search()
                }
            }
            .onChange(of: retrySearch) { _ in
                if retrySearch {
                    Task {
                        await search()
                    }

                    retrySearch = false
                }
            }
            .alert("Bohužel 🙁", isPresented: $showingLessThan2Chars) {
                Button("OK") { }
            } message: {
                Text("Prosím zadej alespoň dva znaky.")
            }
            .alert("Bohužel 🙁", isPresented: $showingFailure) {
                Button("OK") { }
                Button("Zkusit znovu") {
                    retrySearch = true
                }
            } message: {
                Text("Při vyhledávání došlo k chybě.")
            }
        }
    }

    func search() async {
        if searchText.count < 2 {
            showingLessThan2Chars = true
            return
        }

        loadingState = .loading

        let urlString = "https://s.livesport.services/api/v2/search?type-ids=\(getTypeIds())&project-type-id=1&project-id=602&lang-id=1&q=\(searchText)&sport-ids=1,2,3,4,5,6,7,8,9"

        guard let url = URL(string: urlString) else {
            print("Bad URL: \(urlString)")
            showingFailure = true
            loadingState = .failed
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([Result].self, from: data)
            results = decoded
            loadingState = .loaded
        } catch {
            print("Loading results: \(error.localizedDescription)")
            print("URL: \(url)")
            showingFailure = true
            loadingState = .failed
        }

    }

    func getTypeIds() -> String {
        switch selectedEntityType {
        case "Soutěže":
            return "1"
        case "Týmy":
            return "2,3,4"
        default:
            return "1,2,3,4"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
