//
//  TaskProject.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Weerawut Chaiyasomboon on 9/11/2566 BE.
//

import SwiftUI

class TaskProjectViewModel: ObservableObject{
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage() async{
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data,_) = try await URLSession.shared.data(from: url)
            let image = UIImage(data: data)
            await MainActor.run {
                self.image = image
            }
        } catch {
            print("DEBUG: \(error.localizedDescription)")
        }
    }
    
    func fetchImage2() async{
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data,_) = try await URLSession.shared.data(from: url)
            let image = UIImage(data: data)
            await MainActor.run {
                self.image2 = image
            }
        } catch {
            print("DEBUG: \(error.localizedDescription)")
        }
    }
}

struct TaskProjectHome: View{
    var body: some View{
        NavigationStack {
            ZStack {
                NavigationLink("Click Me!") {
                    TaskProject()
                }
            }
        }
    }
}

struct TaskProject: View {
    @StateObject private var viewModel = TaskProjectViewModel()
//    @State private var fetchImageTask: Task<(), Never>? = nil
    
    var body: some View {
        VStack(spacing: 40){
            if let image = viewModel.image{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200,height: 200)
            }
            
            if let image = viewModel.image2{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200,height: 200)
            }
        }
        .task {
            await viewModel.fetchImage()
        }
        /*
        .onDisappear(perform: {
            fetchImageTask?.cancel()
        })
        .onAppear(perform: {
            fetchImageTask = Task{
                await viewModel.fetchImage()
            }
            
//            Task{
//                print(Thread.current)
//                print(Task.currentPriority)
//                await viewModel.fetchImage()
//            }
//            Task{
//                print(Thread.current)
//                print(Task.currentPriority)
//                await viewModel.fetchImage2()
//            }
            
//            Task(priority: .low) {
//                print("LOW: \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .medium) {
//                print("MEDUIM: \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .high) {
////                try? await Task.sleep(nanoseconds: 2_000_000_000)
//                await Task.yield()
//                print("HIGH: \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .background) {
//                print("BACKGROUND: \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .utility) {
//                print("UTILITY: \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .userInitiated) {
//                print("USERINITIATED: \(Thread.current) : \(Task.currentPriority)")
//            }
//            
//            Task(priority: .userInitiated) {
//                print("USERINITIATED: \(Thread.current) : \(Task.currentPriority)")
//                
//                Task{
//                    print("CHILD TASK: \(Thread.current) : \(Task.currentPriority)")
//                }
//            }
        }) */
    }
}

#Preview {
    TaskProject()
}
