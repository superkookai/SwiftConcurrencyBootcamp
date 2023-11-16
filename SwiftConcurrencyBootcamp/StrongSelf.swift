//
//  StrongSelf.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Weerawut Chaiyasomboon on 16/11/2566 BE.
//

import SwiftUI

final class StrongSelfDataService{
    func getData() async -> String{
        "Updated Data!"
    }
}

final class StrongSelfViewModel: ObservableObject{
    @Published var data = "Some title"
    let manager = StrongSelfDataService()
    
    private var someTask: Task<Void,Never>? = nil
    private var myTasks: [Task<Void,Never>] = []
    func cancelTask(){
        someTask?.cancel()
        someTask = nil
        
        myTasks.forEach { task in
            task.cancel()
        }
        myTasks = []
    }
    
    //This is imply strong reference
    func updateData(){
        Task{
            data = await manager.getData()
        }
    }
    
    //This is strong reference
    func updateData2(){
        Task{
            self.data = await manager.getData()
        }
    }
    
    //This is strong reference
    func updateData3(){
        Task{ [self] in
            self.data = await manager.getData()
        }
    }
    
    //This is weak reference
    func updateData4(){
        Task{ [weak self] in
            if let data = await self?.manager.getData(){
                self?.data = data
            }
        }
    }
    
    //We no need to manage strong/weak, We can manage Task
    func updateData5(){
        someTask = Task{
            self.data = await manager.getData()
        }
    }
    
    //Manage many Tasks
    func updateData6(){
        let task1 = Task{
            self.data = await manager.getData()
        }
        myTasks.append(task1)
        
        let task2 = Task{
            self.data = await manager.getData()
        }
        myTasks.append(task2)
    }
}

struct StrongSelf: View {
    @StateObject private var viewModel = StrongSelfViewModel()
    
    var body: some View {
        Text(viewModel.data)
            .onAppear(perform: {
                viewModel.updateData6()
            })
            .onDisappear(perform: {
                viewModel.cancelTask()
            })
    }
}

#Preview {
    StrongSelf()
}
