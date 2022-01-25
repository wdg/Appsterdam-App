//
//  Image.swift
//  Appsterdam
//
//  Created by Wesley de Groot on 24/01/2022.
//

// Original from https://stackoverflow.com/questions/60677622/how-to-display-image-from-a-url-in-swiftui
// Modifications: image download in background.

import SwiftUI
import Aurora

struct RemoteImageView<Placeholder: View, ConfiguredImage: View>: View {
    var url: URL
    private let placeholder: () -> Placeholder
    private let image: (Image) -> ConfiguredImage

    @ObservedObject var imageLoader: ImageLoaderService
    @State var imageData: UIImage?

    init(url: URL,
         @ViewBuilder placeholder: @escaping () -> Placeholder,
         @ViewBuilder image: @escaping (Image) -> ConfiguredImage) {
        self.url = url
        self.placeholder = placeholder
        self.image = image
        self.imageLoader = ImageLoaderService(url: url)
    }

    @ViewBuilder private var imageContent: some View {
        if let data = imageData {
            image(Image(uiImage: data))
        } else {
            placeholder()
        }
    }

    var body: some View {
        imageContent
            .onReceive(imageLoader.$image) { imageData in
                self.imageData = imageData
            }
    }
}

class ImageLoaderService: ObservableObject {
    @Published var image = UIImage()

    convenience init(url: URL) {
        self.init()
        loadImage(for: url)
    }

    func loadImage(for url: URL) {
        DispatchQueue.global(qos: .background).async {
            let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data else { return }
                DispatchQueue.main.async {
                    self.image = UIImage(data: data) ?? UIImage()
                }
            }
            task.resume()
        }
    }
}