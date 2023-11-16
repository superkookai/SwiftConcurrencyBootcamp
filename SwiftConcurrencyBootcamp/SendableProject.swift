//
//  SendableProject.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Weerawut Chaiyasomboon on 16/11/2566 BE.
//

import SwiftUI

struct MyUserInfo: Sendable{
    let name: String
}

actor CurrentUserManager{
    func updateDatabase(userInfo: MyUserInfo){
        
    }
}

class SendableProjectViewModel: ObservableObject{
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async{
        let info = MyUserInfo(name: "John Info")
        await manager.updateDatabase(userInfo: info)
    }
}

struct SendableProject: View {
    @StateObject private var viewModel = SendableProjectViewModel()
    
    var body: some View {
        Text("Hello, World!")
            .task {
                
            }
    }
}

#Preview {
    SendableProject()
}
