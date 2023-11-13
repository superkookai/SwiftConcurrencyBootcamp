//
//  AsyncLet.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Weerawut Chaiyasomboon on 13/11/2566 BE.
//

import SwiftUI

struct AsyncLet: View {
    
    @State private var images: [UIImage] = []
    let columns: [GridItem] = [GridItem(.flexible()),GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/200")!
    
    var body: some View {
        NavigationStack{
            ScrollView{
                LazyVGrid(columns: columns, content: {
                    ForEach(images, id: \.self){ image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                })
            }
            .navigationTitle("Async Let")
            .onAppear(perform: {
                Task{
                    do{
                        //Loding imgaes paralelly
                        async let fetchImage1 = fetchImage()
                        async let fetchImage2 = fetchImage()
                        async let fetchImage3 = fetchImage()
                        async let fetchImage4 = fetchImage()
                        
                        let (image1,image2,image3,image4) = try await (fetchImage1,fetchImage2,fetchImage3,fetchImage4)
                        
                        self.images.append(contentsOf: [image1,image2,image3,image4])
                        
                        //Loading image one by one synchronously
//                        let image1 = try await fetchImage()
//                        self.images.append(image1)
//                        
//                        let image2 = try await fetchImage()
//                        self.images.append(image2)
//                        
//                        let image3 = try await fetchImage()
//                        self.images.append(image3)
//                        
//                        let image4 = try await fetchImage()
//                        self.images.append(image4)
                    }catch{
                        print("DEBUG: \(error.localizedDescription)")
                    }
                }
            })
        }
    }
    
    func fetchImage() async throws -> UIImage{
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

#Preview {
    AsyncLet()
}
