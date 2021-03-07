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
}

protocol ListViewModelOutput {
    var displayNews: ((News) -> Void)? { get set }
    var displayDetail: ((New) -> Void)? { get set }
    var numberState: ((_ current: Int, _ total: Int) -> Void)? { get set }
}

protocol ListViewModel: ListViewModelInput, ListViewModelOutput {
    
}

final class DefaultListViewModel: ListViewModel {
    
    // MARK: - Input
    var onViewWillAppear: (() -> Void)?
    var onSelected: ((IndexPath) -> Void)?
    var onScrollToBottom: (() -> Void)?
    
    // MARL: - Output
    var displayNews: ((News) -> Void)?
    var displayDetail: ((New) -> Void)?
    var numberState: ((_ current: Int, _ total: Int) -> Void)?
    
    private let passValue: News
    private var onScrollingUpdate: Bool = false
    private let newsCount: Int = 40
    private var currentsCount: Int = 0
    
    init(passValue: News) {
        self.passValue = passValue
        
        onSelected = { [weak self] indexPath in
            print(indexPath)
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
}
