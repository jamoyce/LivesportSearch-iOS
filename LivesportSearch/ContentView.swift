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

    let entityTypes = ["All", "Leagues", "Teams"]
    
    @State private var selectedEntityType = "All"
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
                        TextField("Search leagues and teams", text: $searchText)

                        if searchText != "" {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                                .onTapGesture {
                                    searchText = ""
                                }
                        }

                        Button("Search") {
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
                        Text("Search results will be displayed here.")
                    case .loading:
                        Text("Loading results...")
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
                            Text("No result found.")
                        }
                    case .failed:
                        EmptyView()
                    }
                }
            }
            .navigationTitle("Livesport Search")
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
            .alert("Sorry 🙁", isPresented: $showingLessThan2Chars) {
                Button("OK") { }
            } message: {
                Text("Please enter at least 2 characters.")
            }
            .alert("Sorry 🙁", isPresented: $showingFailure) {
                Button("OK") { }
                Button("Try again") {
                    retrySearch = true
                }
            } message: {
                Text("There was an error loading the results.")
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
        case "Leagues":
            return "1"
        case "Teams":
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
