//
//  StructClassActorView.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Weerawut Chaiyasomboon on 15/11/2566 BE.
//

import SwiftUI

struct StructClassActorView: View {
    var body: some View {
        Text("Hello, World!")
            .onAppear(perform: {
                runTest()
            })
    }
}

#Preview {
    StructClassActorView()
}

struct MyStruct{
    var title: String
}

class MyClass{
    var title: String
    init(title: String) {
        self.title = title
    }
    func updateTitle(title: String){
        self.title = title
    }
}

actor MyActor{
    var title: String
    init(title: String) {
        self.title = title
    }
    func updateTitle(title: String){
        self.title = title
    }
}

extension StructClassActorView{
    private func runTest(){
        print("Test start!")
        printLine()
        structTest1()
        printLine()
        classTest1()
        printLine()
        actorTest1()
        
//        structTest2()
    }
    
    private func printLine(){
        print("""
- - - - - - - - - - - - - - - - - - - - - - - - - -
"""
        )
    }
    
    private func structTest1(){
        print("structTest1")
        let objectA = MyStruct(title: "Start Title")
        print("ObjectA: ", objectA.title)

        var objectB = objectA
        print("Pass VALUE from objectA to objectB")
        print("ObjectB: ", objectB.title)
        
        objectB.title = "Second Title" //Create new struct object
        print("Changed title value of ObjectB")
        print("ObjectB: ", objectB.title)
        print("ObjectA: ", objectA.title)
    }
    
    private func classTest1(){
        print("classTest1")
        let objectA = MyClass(title: "Start Title")
        print("ObjectA: ", objectA.title)
        
        let objectB = objectA
        print("Pass Reference from objectA to objectB")
        print("ObjectB: ", objectB.title)
        
        objectB.title = "Second Title" //Change value of title of class object
        print("Changed title value of ObjectB")
        print("ObjectB: ", objectB.title)
        print("ObjectA: ", objectA.title)
    }
    
    private func actorTest1(){
        Task { //or mark func as async
            print("actorTest1")
            let objectA = MyActor(title: "Start Title")
            await print("ObjectA: ", objectA.title)
            
            let objectB = objectA
            print("Pass Reference from objectA to objectB")
            await print("ObjectB: ", objectB.title)
            
            await objectB.updateTitle(title: "Second Title")
            print("Changed title value of ObjectB")
            await print("ObjectB: ", objectB.title)
            await print("ObjectA: ", objectA.title)
        }
    }
}

//Immutable Struct
struct CustomStruct{
    let title: String
    
    func updateTitle(title: String) -> CustomStruct{
        CustomStruct(title: title)
    }
}

struct MutableStruct{
    private(set) var title: String
    
    mutating func updateTitle(title: String) {
        self.title = title
    }
}

extension StructClassActorView{
    private func structTest2(){
        print("structTest2")
        
        //Mutable Struct
        print("Mutable Struct - - - - - - - - -")
        let struct1 = MyStruct(title: "Title1")
        print("Struct1: ", struct1.title)
        
        var struct2 = struct1
        print("Pass VALUE from struct1 to struct2")
        print("Struct2: ", struct2.title)
        struct2.title = "New Title" //In the background, create new Struct
        print("Changed title value of struct2")
        print("Struct1: ", struct1.title)
        print("Struct2: ", struct2.title)
        
        //Immutable Struct
        print("Immutable Struct - - - - - - - - -")
        var customStruct = CustomStruct(title: "CustomTitle1")
        print("CustomStruct ", customStruct.title)
        
        customStruct = CustomStruct(title: "CustomTitle2") //Same with update value in Mutable Struct
        print("CustomStruct ", customStruct.title)
        
        customStruct = customStruct.updateTitle(title: "CustomTitle3")
        print("CustomStruct ", customStruct.title)
        
        //Mutable Struct with mutating function
        print("Mutable Struct with mutating function - - - - - - - - -")
        var struct3 = MutableStruct(title: "Struct3")
        print("Struct3: ", struct3.title)
        struct3.updateTitle(title: "New Title For Struct3") //Create new Struct
        print("Struct3: ", struct3.title)
    }
}
