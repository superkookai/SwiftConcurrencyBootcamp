//
//  AsyncAwait.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Weerawut Chaiyasomboon on 9/11/2566 BE.
//

import SwiftUI

class AsyncAwaitViewModel: ObservableObject{
    @Published var dataArray: [String] = []
    
    func addTitle1(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            self.dataArray.append("Title1: \(Thread.current)")
        }
    }
    
    func addTitle2(){
        DispatchQueue.global().asyncAfter(deadline: .now()+2){
            let title = "Title2: \(Thread.current)"
            DispatchQueue.main.async {
                self.dataArray.append(title)
            }
        }
    }
    
    func addAuthor1() async {
        let author1 = "Author1: \(Thread.current)"
        await MainActor.run {
            self.dataArray.append(author1)
        }
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let author2 = "Author2: \(Thread.current)"
        await MainActor.run {
            self.dataArray.append(author2)
            
            let author3 = "Author3: \(Thread.current)"
            self.dataArray.append(author3)
        }
        
        await addSomething()
        
    }
    
    func addSomething() async{
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let something1 = "Something1: \(Thread.current)"
        await MainActor.run {
            self.dataArray.append(something1)
            
            let something2 = "Something2: \(Thread.current)"
            self.dataArray.append(something2)
        }
    }
}

struct AsyncAwait: View {
    @StateObject private var viewModel = AsyncAwaitViewModel()
    
    var body: some View {
        List{
            ForEach(viewModel.dataArray, id: \.self){ data in
                Text(data)
            }
        }
        .onAppear(perform: {
//            viewModel.addTitle1()
//            viewModel.addTitle2()
            
            Task{
                await viewModel.addAuthor1()
                
                let final = "Final Text: \(Thread.current)"
                viewModel.dataArray.append(final)
            }
        })
    }
}

#Preview {
    AsyncAwait()
}
