//
//  PhotoPicker.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Weerawut Chaiyasomboon on 17/11/2566 BE.
//

import SwiftUI
import PhotosUI

@MainActor
final class PhotoPickerViewModel: ObservableObject{
    @Published private(set) var selectedImage: UIImage? = nil
    @Published var imagePickerItem: PhotosPickerItem? = nil{
        didSet{
            setImage(from: imagePickerItem)
        }
    }
    
    @Published private(set) var selectedImages: [UIImage] = []
    @Published var imagePickerItems: [PhotosPickerItem] = []{
        didSet{
            setImages(from: imagePickerItems)
        }
    }
    
    private func setImage(from selection: PhotosPickerItem?){
        guard let selection else {return}
        Task{
            do{
                let data = try await selection.loadTransferable(type: Data.self)
                guard let data, let uiImage = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                selectedImage = uiImage
            }catch{
                print("DEBUG: \(error.localizedDescription)")
            }
        }
    }
    
    private func setImages(from selections: [PhotosPickerItem]?){
        guard let selections else {return}
        Task{
            var images: [UIImage] = []
            for selection in selections{
                if let data = try? await selection.loadTransferable(type: Data.self){
                    if let uiImage = UIImage(data: data){
                        images.append(uiImage)
                    }
                }
            }
            selectedImages = images
        }
    }
}

struct PhotoPicker: View {
    @StateObject private var viewModel = PhotoPickerViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Pick an Image")
            
            if let image = viewModel.selectedImage{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .cornerRadius(10)
            }
            
            PhotosPicker(selection: $viewModel.imagePickerItem, matching: .images) {
                Text("Open the Photos Picker!")
            }
            
            if !viewModel.selectedImages.isEmpty{
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack{
                        ForEach(viewModel.selectedImages, id: \.self){ image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 200)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            
            PhotosPicker(selection: $viewModel.imagePickerItems, matching: .images) {
                Text("Open the Photos Picker! [Select multiple images]")
            }
        }
    }
}

#Preview {
    PhotoPicker()
}
