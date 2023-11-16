//
//  GlobalActor.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Weerawut Chaiyasomboon on 16/11/2566 BE.
//

import SwiftUI

@globalActor struct MyFirstGlobalActor{
    static var shared = MyNewDataManager()
}

actor MyNewDataManager{
    
    func getDataFromDatabase() -> [String]{
        return ["One","Two","Three","Four","Five","Six","Seven"]
    }
}

class GlobalActorViewModel: ObservableObject{
    @Published var dataArray: [String] = []
    let manager = MyFirstGlobalActor.shared
    
    @MyFirstGlobalActor
    func getData() async {
        let data = await manager.getDataFromDatabase()
        await MainActor.run {
            self.dataArray = data
        }
    }
}

struct GlobalActor: View {
    @StateObject private var viewModel = GlobalActorViewModel()
    
    var body: some View {
        ScrollView{
            VStack{
                ForEach(viewModel.dataArray, id: \.self){
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.getData()
        }
    }
}

#Preview {
    GlobalActor()
}
