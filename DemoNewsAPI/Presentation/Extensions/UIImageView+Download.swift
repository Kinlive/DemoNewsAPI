//
//  UIImageView+Download.swift
//
//
//  Created by KinWei on 2021/3/7.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

private let downloadImageQueue = DispatchQueue(label: "com.demo.downloadImage",
                                               qos: .background,
                                               attributes: [.concurrent],
                                               autoreleaseFrequency: .never)

extension UIImageView {
    
  private var imageCacher: Cache<String, UIImage> {
    return CacheManager.shared.imageCache
  }
    
  func downloaded(from url: URL,
          contentMode mode: UIView.ContentMode = .scaleAspectFit,
               placeholder: UIImage = UIImage(named: "placeholder")!) {
    defer { if image == nil { image = placeholder } }
    contentMode = mode

    let item = DispatchWorkItem {
      if let image = self.imageCacher.value(forKey: url.absoluteString) {
          DispatchQueue.main.async() {
              self.image = image
          }
          return
      }

      URLSession.shared.dataTask(with: url) { data, response, error in
        if let httpURLResponse = response as? HTTPURLResponse, (200 ..< 300) ~= httpURLResponse.statusCode ,
              let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
              let data = data, error == nil,
              let image = UIImage(data: data) {
              self.imageCacher.insert(image, forKey: url.absoluteString)
              DispatchQueue.main.async() {
                  self.image = image
              }
          } else { // if haven't mimeType image use Data(link) to get.
              self.downloadImage(from: url, placeholder: placeholder)
          }

      }.resume()
    }

    downloadImageQueue.async(execute: item)
  }
    
  func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit, placeholder: UIImage = UIImage(named: "placeholder")!) {
      defer { if image == nil { image = placeholder } }

      guard let url = URL(string: link) else { return }
      downloaded(from: url, contentMode: mode)
  }

  private func downloadImage(from link: URL, placeholder: UIImage) {
    defer { DispatchQueue.main.async { if self.image == nil { self.image = placeholder } } }

    let item = DispatchWorkItem {
      do {
          let data = try? Data(contentsOf: link)
          if let data = data, let image = UIImage(data: data) {
              self.imageCacher.insert(image, forKey: link.absoluteString)

              DispatchQueue.main.async {
                  self.image = image
              }
          }
      }
    }

    downloadImageQueue.async(execute: item)
    
  }
}
