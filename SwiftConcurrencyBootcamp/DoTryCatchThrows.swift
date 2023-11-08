//
//  DoTryCatchThrows.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Weerawut Chaiyasomboon on 8/11/2566 BE.
//

import SwiftUI

class DoTryCatchThrowsManager{
    
    var isActive = true
    
    func getTitle() -> Result<String, Error>{
        if isActive{
            return .success("GOT NEW TITLE")
        }else{
            return .failure(URLError(.badURL))
        }
    }
    
    func getTitle2() throws -> String{
        if isActive{
            return "GOT NEW TITLE"
        }else{
            throw URLError(.badURL)
        }
    }
}

class DoTryCatchThrowsViewModel: ObservableObject{
    @Published var text: String = "Initial Text"
    let manager = DoTryCatchThrowsManager()
    
    func fetchNewText(){
//        let result = manager.getTitle()
//        switch result{
//        case .success(let title):
//            self.text = title
//        case .failure(let error):
//            self.text = error.localizedDescription
//        }
        
        do {
            self.text = try manager.getTitle2()
        }catch(let error){
            self.text = error.localizedDescription
        }
    }
}

struct DoTryCatchThrows: View {
    @StateObject private var viewModel = DoTryCatchThrowsViewModel()
    
    var body: some View {
        Text(viewModel.text)
            .font(.title)
            .frame(width: 300, height: 300)
            .background(Color.green)
            .onTapGesture {
                viewModel.fetchNewText()
            }
    }
}

#Preview {
    DoTryCatchThrows()
}
