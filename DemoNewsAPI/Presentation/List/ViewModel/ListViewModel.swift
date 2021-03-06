//
//  ListViewModel.swift
//  DemoNewsAPI
//
//  Created by KinWei on 2021/3/6.
//

import Foundation

protocol ListViewModelInput {
    var onViewWillAppear: (() -> Void)? { get }
    var onSelected: ((IndexPath) -> Void)? { get }
    var onScrollToBottom: (() -> Void)? { get }
    var onCellWillDisplay: ((IndexPath) -> Void)? { get }
    var onCellDidEndDisplay: ((IndexPath) -> Void)? { get }
    var onCellForRow: ((Int) -> ImageDownloadTask?)? { get }
}

protocol ListViewModelOutput {
    var displayNews: ((News) -> Void)? { get set }
    var displayDetail: ((New) -> Void)? { get set }
    var numberState: ((_ current: Int, _ total: Int) -> Void)? { get set }
    var onImageDownloaded: ((Int) -> Void)? { get set }
    
}

protocol ListViewModel: ListViewModelInput, ListViewModelOutput {
    
}

final class DefaultListViewModel: ListViewModel {
    
    // MARK: - Input
    var onViewWillAppear: (() -> Void)?
    var onSelected: ((IndexPath) -> Void)?
    var onScrollToBottom: (() -> Void)?
    var onCellWillDisplay: ((IndexPath) -> Void)?
    var onCellDidEndDisplay: ((IndexPath) -> Void)?
    var onCellForRow: ((Int) -> ImageDownloadTask?)?
    
    // MARL: - Output
    var displayNews: ((News) -> Void)?
    var displayDetail: ((New) -> Void)?
    var numberState: ((_ current: Int, _ total: Int) -> Void)?
    var onImageDownloaded: ((Int) -> Void)?
    
    private let passValue: News
    private var onScrollingUpdate: Bool = false
    private let newsCount: Int = 40
    private var currentsCount: Int = 0
    private var imageTasks: [Int : ImageDownloadTask] = [:]
    
    init(passValue: News) {
        self.passValue = passValue
        
        onSelected = { [weak self] indexPath in
            self?.getNew(at: indexPath)
        }
        
        onViewWillAppear = { [weak self] in
            self?.handleNeedToDisplayNews()
        }
        
        onScrollToBottom = { [weak self] in
            guard self?.onScrollingUpdate == false else { return }
            self?.onScrollingUpdate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self?.onScrollingUpdate = false
            }
            self?.handleNeedToDisplayNews()
        }
        
        onCellWillDisplay = { [weak self] indexPath in
            self?.imageTasks[indexPath.row]?.resume()
        }
        
        onCellDidEndDisplay = { [weak self] indexPath in
            self?.imageTasks[indexPath.row]?.pause()
        }
        
        onCellForRow = { [weak self] index -> ImageDownloadTask? in
            return self?.imageTasks[index]
        }
        
        setupImageTasks(totalImages: passValue.count)
    }
    
}

private extension DefaultListViewModel {
    func selectedNew(at indexPath: IndexPath) -> New {
        
        return passValue[indexPath.row]
    }
    
    func handleNeedToDisplayNews() {
        currentsCount += newsCount
        if currentsCount < passValue.count {
            displayNews?(Array(passValue[...currentsCount]))
            numberState?(currentsCount, passValue.count)
        } else {
            displayNews?(passValue)
            numberState?(passValue.count, passValue.count)
        }
    }
    
    func getNew(at indexPath: IndexPath) {
        let new = passValue[indexPath.row]
        displayDetail?(new)
    }
    
    func setupImageTasks(totalImages: Int) {
        let session = URLSession(configuration: .default)
        
        for i in 0 ..< totalImages {
            if let url = URL(string: passValue[i].url) {
                let imageTask = ImageDownloadTask(position: i, url: url, session: session, delegate: self)
                imageTasks[i] = imageTask
            }
            
        }
    }
}

extension DefaultListViewModel: ImageTaskDownloadDelegate {
    func imageDownloadedPosition(_ position: Int) {
        onImageDownloaded?(position)
    }
}
