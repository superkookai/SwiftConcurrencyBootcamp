//
//  AsyncPublisherProject.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Weerawut Chaiyasomboon on 16/11/2566 BE.
//

import SwiftUI

actor AsyncPublisherDataManager{
    @Published var myData: [String] = []
    
    func addData() async{
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Watermellon")
    }
}

class AsyncPublisherViewModel: ObservableObject{
    let manager = AsyncPublisherDataManager()
    @MainActor @Published var dataArray: [String] = []
    
    init(){
        addSubcribers()
    }
    
    private func addSubcribers(){
        Task{
            for await value in await manager.$myData.values{
                await MainActor.run {
                    self.dataArray = value
                }
            }
        }
    }
    
    func start() async{
        await manager.addData()
    }
}

struct AsyncPublisherProject: View {
    @StateObject private var viewModel = AsyncPublisherViewModel()
    
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
            await viewModel.start()
        }
    }
}

#Preview {
    AsyncPublisherProject()
}
