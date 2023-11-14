//
//  TaskGroupView.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Weerawut Chaiyasomboon on 14/11/2566 BE.
//

import SwiftUI

class TaskGroupDataManager{
    
    let urlString = "https://picsum.photos/200"
    
    func fetchImagesWithAsyncLet() async throws-> [UIImage]{
        do{
            async let fetchImage1 = fetchImage(urlString: urlString)
            async let fetchImage2 = fetchImage(urlString: urlString)
            async let fetchImage3 = fetchImage(urlString: urlString)
            async let fetchImage4 = fetchImage(urlString: urlString)
            
            let (image1,image2,image3,image4) = try await (fetchImage1,fetchImage2,fetchImage3,fetchImage4)
            
            return [image1,image2,image3,image4]
        }catch{
            throw error
        }
    }
    
    func fetchImagesWithTaskGroup() async throws-> [UIImage]{
        let urlStrings = [
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200"
        ]
        
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images: [UIImage] = []
            images.reserveCapacity(urlStrings.count)
            
            for urlString in urlStrings{
                group.addTask {
                    try? await self.fetchImage(urlString: urlString)
                }
            }
            
            for try await image in group{
                if let image = image{
                    images.append(image)
                }
            }
            
            return images
        }
    }
    
    private func fetchImage(urlString: String) async throws -> UIImage{
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        do{
            let (data,_) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data){
                return image
            }else{
                throw URLError(.badURL)
            }
        }catch{
            throw error
        }
    }
}

class TaskGroupViewModel: ObservableObject{
    @Published var images: [UIImage] = []
    let manager = TaskGroupDataManager()
    
    func getImages() async{
        if let images = try? await manager.fetchImagesWithTaskGroup(){
            self.images.append(contentsOf: images)
        }
        
//        if let images = try? await manager.fetchImagesWithAsyncLet(){
//            self.images.append(contentsOf: images)
//        }
    }
}

struct TaskGroupView: View {
    @StateObject private var viewModel = TaskGroupViewModel()
    let columns: [GridItem] = [GridItem(.flexible()),GridItem(.flexible())]
    
    var body: some View {
        NavigationStack{
            ScrollView{
                LazyVGrid(columns: columns, content: {
                    ForEach(viewModel.images, id: \.self){ image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                })
            }
            .navigationTitle("Task Group")
            .task {
                await viewModel.getImages()
            }
        }
    }
}

#Preview {
    TaskGroupView()
}
