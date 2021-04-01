//
//  ProgressiveBufferedImageView.swift
//  DemoNewsAPI
//
//  Created by KinWei on 2021/4/1.
//

import UIKit

class ProgressiveBufferedImageView: UIImageView {

    fileprivate lazy var session: URLSession = {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: queue)
        return session
    }()
    
    fileprivate var task: URLSessionDataTask?
    fileprivate var data: Data = Data()
    
    fileprivate let queue: OperationQueue = {
        let queue = OperationQueue()
        //queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    fileprivate var isFinished: Bool = false
    
    open var loadedHandler: (() -> Void)?
    
    deinit {
        session.invalidateAndCancel()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .gray
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .gray
    }
    
    open func load(url: URL) {
        task = session.dataTask(with: URLRequest(url: url))
        task?.resume()
    }
    
    lazy var imageSource: CGImageSource = {
        let source = CGImageSourceCreateIncremental(nil)
        return source
    }()
    
    private func decodingImage() {
        queue.addOperation {
            CGImageSourceUpdateData(self.imageSource, self.data as CFData, self.isFinished)
            
            guard let cgImage = CGImageSourceCreateImageAtIndex(self.imageSource, 0, nil) else { print("Image could not being created.") ;return }
            
            DispatchQueue.main.async {
                self.image = UIImage(cgImage: cgImage)
            }
        }
    }
}

extension ProgressiveBufferedImageView: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        isFinished = true
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.data.append(data)
        
        decodingImage()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        completionHandler(.allow)
    }
    
}
