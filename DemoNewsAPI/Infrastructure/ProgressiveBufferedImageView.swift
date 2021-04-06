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
        return queue
    }()
    
    fileprivate var isFinished: Bool = false
    
    private var drawTimer: Timer?
    private var downloadImage: UIImage?
    
    deinit {
        session.invalidateAndCancel()
        if let timer = drawTimer {
            timer.invalidate()
            drawTimer = nil
        }
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
            
            self.downloadImage = UIImage(cgImage: cgImage)
        }
    }
    
    @objc private func drawImage() {
        DispatchQueue.main.async {
            self.image = self.downloadImage
        }
        
        if isFinished {
            if let timer = drawTimer {
                timer.invalidate()
                drawTimer = nil
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
        DispatchQueue.main.async {
            self.drawTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.drawImage), userInfo: nil, repeats: true)
        }
    }
}
