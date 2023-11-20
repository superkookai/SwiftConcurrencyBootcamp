//
//  SearchableProject.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Weerawut Chaiyasomboon on 20/11/2566 BE.
//

import SwiftUI
import Combine

enum CuisineOption: String{
    case american, italian, japanese
}

struct Restuarant: Identifiable, Hashable{
    let id: String
    let title: String
    let cuisine: CuisineOption
}

final class RestuarantManager{
    
    func getAllRestuarant() async throws -> [Restuarant]{
        [
            Restuarant(id: "1", title: "Burger Shack", cuisine: .american),
            Restuarant(id: "2", title: "Pasta Sauaces", cuisine: .italian),
            Restuarant(id: "3", title: "Sushi Do", cuisine: .japanese),
            Restuarant(id: "4", title: "Pork Chop", cuisine: .american),
            Restuarant(id: "5", title: "Pizza Hawaian", cuisine: .italian),
            Restuarant(id: "6", title: "Tempura", cuisine: .japanese)
            
        ]
    }
}

@MainActor
final class SearchableViewModel: ObservableObject{
    let manager = RestuarantManager()
    
    @Published private(set) var allRestuarants: [Restuarant] = []
    @Published private(set) var filteredRestuarants: [Restuarant] = []
    @Published var searchText: String = ""
    @Published var searchScope: SearchScopeOption = .all
    @Published private(set) var allSearchScopes: [SearchScopeOption] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    var isSearching: Bool{
        !searchText.isEmpty
    }
    
    var showSearchSuggestions: Bool{
        searchText.count < 5
    }
    
    enum SearchScopeOption: Hashable{
        case all
        case cuisine(option: CuisineOption)
        var title: String{
            switch self{
            case .all: return "All"
            case .cuisine(option: let option): return option.rawValue.capitalized
            }
        }
    }
    
    init(){
        addSubcribers()
    }
    
    private func addSubcribers(){
        $searchText
            .combineLatest($searchScope)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] (searchText,searchScope) in
                self?.filterRestuarants(searchText: searchText, currentSearchScope: searchScope)
            }
            .store(in: &cancellables)
    }
    
    private func filterRestuarants(searchText: String, currentSearchScope: SearchScopeOption){
        guard !searchText.isEmpty else {
            filteredRestuarants = []
            searchScope = .all
            return
        }
        
        //Filter on search scope
        var restuarantsInScope = allRestuarants
        switch currentSearchScope{
        case .all:
            break
        case .cuisine(let option):
            restuarantsInScope = allRestuarants.filter({ $0.cuisine == option })
        }
        
        //Filter on search text
        let search = searchText.lowercased()
        filteredRestuarants = restuarantsInScope.filter({ restuarant in
            let titleContainSearch = restuarant.title.lowercased().contains(search)
            let cuisineContainSearch = restuarant.cuisine.rawValue.lowercased().contains(search)
            return titleContainSearch || cuisineContainSearch
        })
    }
    
    func loadRestuarants() async {
        do{
            allRestuarants = try await manager.getAllRestuarant()
            
            let allCuisines = Set(allRestuarants.map { $0.cuisine })
            allSearchScopes = [.all] + allCuisines.map{SearchScopeOption.cuisine(option: $0)}
        }
        catch{
            print("DEBUG: \(error.localizedDescription)")
        }
    }
    
    func getSearchSuggestions() -> [String]{
        guard showSearchSuggestions else { return [] }
        
        var suggestions = [String]()
        
        let search = searchText.lowercased()
        if search.contains("pa"){
            suggestions.append("Pasta")
        }
        
        if search.contains("bu"){
            suggestions.append("Burger")
        }
        
        if search.contains("su"){
            suggestions.append("Shuhi")
        }
        
        suggestions.append("Market")
        suggestions.append("Grocery")
        
        suggestions.append(CuisineOption.american.rawValue.capitalized)
        suggestions.append(CuisineOption.italian.rawValue.capitalized)
        suggestions.append(CuisineOption.japanese.rawValue.capitalized)
        
        return suggestions
    }
    
    func getRestuarantSuggestions() -> [Restuarant]{
        guard showSearchSuggestions else { return [] }
        
        var suggestions = [Restuarant]()
        
        let search = searchText.lowercased()
        if search.contains("ita"){
            suggestions.append(contentsOf: allRestuarants.filter({$0.cuisine == .italian}))
        }
        if search.contains("jap"){
            suggestions.append(contentsOf: allRestuarants.filter({$0.cuisine == .japanese}))
        }
        if search.contains("ame"){
            suggestions.append(contentsOf: allRestuarants.filter({$0.cuisine == .american}))
        }
        
        return suggestions
    }
}

struct SearchableProject: View {
    @StateObject private var viewModel = SearchableViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack(alignment: .leading, spacing: 20){
                    ForEach(viewModel.isSearching ? viewModel.filteredRestuarants : viewModel.allRestuarants){ restuarant in
                        NavigationLink(value: restuarant, label: {
                            restuarantRow(restuarant: restuarant)
                        })
                    }
                }
                .padding()
                
                Text("ViewModel is searching: \(viewModel.isSearching.description)")
                SearchChildView()
                
            }
            .searchable(text: $viewModel.searchText, placement: .automatic, prompt: Text("Search restuarant..."))
            .searchScopes($viewModel.searchScope, scopes: {
                ForEach(viewModel.allSearchScopes, id: \.self){ Text($0.title).tag($0) }
            })
            .searchSuggestions({
                ForEach(viewModel.getSearchSuggestions(), id: \.self){
                    Text($0)
                        .searchCompletion($0)
                }
                ForEach(viewModel.getRestuarantSuggestions()){ restuarant in
                    NavigationLink(value: restuarant) {
                        restuarantRow(restuarant: restuarant)
                    }
                }
            })
            .navigationTitle("Restuarants")
            .task {
                await viewModel.loadRestuarants()
            }
            .navigationDestination(for: Restuarant.self) { restuarant in
                Text(restuarant.title.uppercased())
                    .font(.title)
            }
        }
    }
    
    private func restuarantRow(restuarant: Restuarant) -> some View{
        VStack(alignment: .leading, spacing: 10, content: {
            Text(restuarant.title)
                .font(.headline)
                .foregroundStyle(.red)
            Text(restuarant.cuisine.rawValue.capitalized)
                .font(.caption)
        })
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.05))
    }
}

struct SearchChildView: View {
    @Environment(\.isSearching) private var isSearching
    
    var body: some View {
        Text("Child view is searching: \(isSearching.description)")
    }
}

#Preview {
    SearchableProject()
}
