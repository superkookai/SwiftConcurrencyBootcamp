//
//  MVVM.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Weerawut Chaiyasomboon on 16/11/2566 BE.
//

import SwiftUI

final class MyManagerClass{
    func getData() async throws -> String{
        "Some Data! From class."
    }
}

actor MyManagerActor{
    func getData() async throws -> String{
        "Some Data! From actor."
    }
}

@MainActor
final class MVVMViewModel: ObservableObject{
    let managerClass = MyManagerClass()
    let managerActor = MyManagerActor()
    private var tasks: [Task<Void,Never>] = []
    
    @Published private(set) var myData: String = "Starting text!"
    
    func cancelTasks(){
        tasks.forEach { task in
            task.cancel()
        }
        tasks = []
    }
    
    func onCallToActionButtonPressed(){
        let task = Task{
            do{
//                myData = try await managerClass.getData()
                myData = try await managerActor.getData()
            }catch{
                print("DEBUG: \(error.localizedDescription)")
            }
        }
        tasks.append(task)
    }
}

struct MVVM: View {
    @StateObject private var viewModel = MVVMViewModel()
    
    var body: some View {
        Button(viewModel.myData) {
            viewModel.onCallToActionButtonPressed()
        }
        .onDisappear(perform: {
            viewModel.cancelTasks()
        })
    }
}

#Preview {
    MVVM()
}
