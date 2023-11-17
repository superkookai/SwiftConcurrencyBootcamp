//
//  Refeshable.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Weerawut Chaiyasomboon on 17/11/2566 BE.
//

import SwiftUI

final class RefeshableDataService{
    func getData() async throws -> [String]{
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        return ["Apple","Banana","Orange"].shuffled()
    }
}

@MainActor
final class RefeshableViewModel: ObservableObject{
    @Published private(set) var items: [String] = []
    let manager = RefeshableDataService()
    
    func loadData() async{
            do{
                items = try await manager.getData()
            }catch{
                print("DEBUG: \(error.localizedDescription)")
            }
    }
}

struct Refeshable: View {
    @StateObject private var viewModel = RefeshableViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack{
                    ForEach(viewModel.items, id: \.self){ item in
                        Text(item)
                    }
                }
            }
            .navigationTitle("Refeshable")
            .task {
                await viewModel.loadData()
            }
            .refreshable {
                await viewModel.loadData()
            }
        }
    }
}

#Preview {
    Refeshable()
}
