//
//  ImageDownloadTask.swift
//  DemoNewsAPI
//
//  Created by KinWei on 2021/3/31.
//

import UIKit

protocol ImageTaskDownloadDelegate: class {
    func imageDownloadedPosition(_ position: Int)
}
class ImageDownloadTask {
    
    let position: Int
    let url: URL
    let session: URLSession
    weak var delegate: ImageTaskDownloadDelegate?
    
    var image: UIImage?
    
    private var task: URLSessionDownloadTask?
    private var resumeData: Data?
    
    private var isDownloading = false
    private var isFinishedDownloading = false
    
    init(position: Int, url: URL, session: URLSession, delegate: ImageTaskDownloadDelegate) {
        self.position = position
        self.url = url
        self.session = session
        self.delegate = delegate
    }
    
    func resume() {
        if !isDownloading && !isFinishedDownloading {
            isDownloading = true
            
            if let resumeData = resumeData {
                task = session.downloadTask(withResumeData: resumeData, completionHandler: downloadTaskCompletionHandler)
            } else {
                task = session.downloadTask(with: url, completionHandler: downloadTaskCompletionHandler)
            }
            
            task?.resume()
        }
    }
    
    func pause() {
        if isDownloading && !isFinishedDownloading {
            
            task?.cancel(byProducingResumeData: { [weak self] resumeData in
                self?.resumeData = resumeData
            })
            
            isDownloading = false
        }
    }
    
    private func downloadTaskCompletionHandler(url: URL?, reponse: URLResponse?, error: Error?) {
        
        if let error = error {
            print("Error downloading: \(error)")
            return
        }
        
        guard let url = url,
              let data = FileManager.default.contents(atPath: url.path), // download end the data path.
              let image = UIImage(data: data)
              else { return }
        
        DispatchQueue.main.async {
            self.image = image
            self.delegate?.imageDownloadedPosition(self.position)
        }
        isFinishedDownloading = true
    }
}

