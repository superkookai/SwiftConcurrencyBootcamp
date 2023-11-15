//
//  CheckedContinuation.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Weerawut Chaiyasomboon on 14/11/2566 BE.
//

import SwiftUI

class CheckedContinuationNetworkManager{
    
    func getData(url: URL) async throws -> Data{
        do {
            let (data,_) = try await URLSession.shared.data(from: url)
            return data
        } catch  {
            throw error
        }
    }
    
    func getData2(url: URL) async throws -> Data{
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data{
                    continuation.resume(returning: data)
                }else if let error = error{
                    continuation.resume(throwing: error)
                }else{
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        }
    }
    
    func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage)->Void){
        DispatchQueue.main.asyncAfter(deadline: .now() + 5){
            completionHandler(UIImage(systemName: "heart.fill")!)
        }
    }
    
    func getHeartImageFromDatabase() async -> UIImage{
        return await withCheckedContinuation { continuation in
            getHeartImageFromDatabase { image in
                continuation.resume(returning: image)
            }
        }
    }
}

class CheckedContinuationViewModel: ObservableObject{
    @Published var image: UIImage? = nil
    let manager = CheckedContinuationNetworkManager()
    
    func getImage() async{
        guard let url = URL(string: "https://picsum.photos/200") else { return }
        do {
            let data = try await manager.getData(url: url)
            if let image = UIImage(data: data){
                await MainActor.run {
                    self.image = image
                }
            }
        } catch  {
            print("DEBUG: \(error.localizedDescription)")
        }
    }
    
    func getImage2() async{
        guard let url = URL(string: "https://picsum.photos/200") else { return }
        do {
            let data = try await manager.getData2(url: url)
            if let image = UIImage(data: data){
                await MainActor.run {
                    self.image = image
                }
            }
        } catch  {
            print("DEBUG: \(error.localizedDescription)")
        }
    }
    
    func getHeartImage() {
        manager.getHeartImageFromDatabase { [weak self] image in
            self?.image = image
        }
    }
    
    func getHeartImage2() async{
        let image = await manager.getHeartImageFromDatabase()
        await MainActor.run {
            self.image = image
        }
    }
}

struct CheckedContinuation: View {
    
    @StateObject private var viewModel = CheckedContinuationViewModel()
    
    var body: some View {
        ZStack{
            if let image = viewModel.image{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200,height: 200)
            }
        }
        .task {
//            await viewModel.getImage2()
//            viewModel.getHeartImage()
            await viewModel.getHeartImage2()
        }
    }
}

#Preview {
    CheckedContinuation()
}
