//
//  ContentView.swift
//  FileManagerPick
//
//  Created by Guru Mahan on 04/01/23.
//

import SwiftUI

class CacheManager {
    static let instance = CacheManager()
    
    private init() {
        
    }
    
    var imageCache: NSCache<NSString, UIImage> = {
        
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100
        return cache
        
    }()
    
    func add(image: UIImage, name: String) {
        imageCache.setObject(image, forKey: name as NSString)
        print("Added to cache!")
    }
    
    func remove(name: String) {
        imageCache.removeObject(forKey: name as NSString)
        print("remove from catch!")
    }
    
    func get(name: String) -> UIImage? {
        return imageCache.object(forKey: name as NSString)
    }
    
}
class CacheViewModel: ObservableObject {
    
    @Published var startingImage: UIImage? = nil
    @Published var cachedImage: UIImage? = nil
    
    let newManager = CacheManager.instance
    let imageName = "person.crop.circle"
   
    
    init(){
        getImageFromAssetsFolder()
    }
    
    func getImageFromAssetsFolder(){
      startingImage = UIImage(systemName: imageName )
    }
    
    func saveToCache() {
        guard let image = startingImage else {return}
        newManager.add(image: image, name: imageName)
    }
    
    func removeFromCache(){
        newManager.remove(name: imageName)
    }
    
    func getFromCache() {
        cachedImage = newManager.get(name: imageName)
    }
}
struct ContentView: View {

@StateObject var vm = CacheViewModel()

    @State var selected = false
   @State var image = UIImage(systemName: "globe")!
    @State var fileURL: URL?
       
    var body: some View {
        NavigationView {
            
            
            VStack (spacing: 55) {
                
                Button {
                    selected = true
                } label: {
                    if let image = vm.startingImage {
                        
                            Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200,height: 200)
                            .clipped()
                            .cornerRadius(100)
                    }
                  
                }
                VStack{
                    HStack{
                        Button {
                            vm.saveToCache()
                        } label: {
                            Text("Save to Cache")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                            
                        }
                        
                        Button {
                            vm.removeFromCache()
                        } label: {
                            Text("Delete From Cache")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                            
                        }
                        
                    }
                    Button {
                        vm.getFromCache()
                    } label: {
                        Text("Get From Cache")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                        
                    }
                    
                    if let image = vm.cachedImage {
                            Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200,height: 200)
                            .clipped()
                            .cornerRadius(100)
                    }
                }
              Spacer()
            }
            .navigationTitle("Cache Image")
        }
        .fileImporter(isPresented: $selected, allowedContentTypes: [.image,.audio,.data]) { result in
            
            do {
                
                let furl = try result.get()
                if furl.startAccessingSecurityScopedResource(){
                    let data = try Data(contentsOf: furl)
                    if let img = UIImage(data: data) {
                        print(furl)
                        vm.startingImage = img
                        
                      //  self.fileName = furl.lastPathComponent
                        
                    }
                    furl.stopAccessingSecurityScopedResource()
                }
                
                
            } catch {
                print("error: \(error)") // todo
            }
            
        }
        
    }
    init(){
        saveImage()
    }
    func saveImage() {
           do {
               let furl = try FileManager.default
                   .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                   .appendingPathComponent("imageFile")
                   .appendingPathExtension("png")
               fileURL = furl
               try image.pngData()?.write(to: furl)
           } catch {
               print("could not create imageFile")
           }
       }
    
    
    func loadImage() -> UIImage {
        do {
            if let furl = fileURL {
                let data = try Data(contentsOf: furl)
                if let img = UIImage(data: data) {
                    return img
                }
            }
        } catch {
            print("error: \(error)") // todo
        }
        return UIImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



