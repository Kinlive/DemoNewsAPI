//
//  HomeViewModel.swift
//  DemoNewsAPI
//
//  Created by KinWei on 2021/3/7.
//

import Foundation


protocol HomeViewModelInput {
    var onStartFetch: (() -> Void)? { get set }
}

protocol HomeViewModelOutput {
    var onNewsLoaded: ((News) -> Void)? { get }
    var onFetchError: ((String) -> Void)? { get }
    var isLoading: ((Bool) -> Void)? { get }
}

protocol HomeViewModel: HomeViewModelInput, HomeViewModelOutput {
}

final class DefaultHomeViewModel: HomeViewModel {
    var onFetchError: ((String) -> Void)?
    
    var isLoading: ((Bool) -> Void)?
    
    var onStartFetch: (() -> Void)?
    
    var onNewsLoaded: ((News) -> Void)?
    
    private let service = APIService.shared
    
    init() {
        onStartFetch = { [weak self] in
            self?.requestNews()
        }
    }
    
    private func requestNews() {
        isLoading?(true)
        
        service.request { [weak self] result in
            self?.isLoading?(false)
            switch result {
            case .success(let news): self?.onNewsLoaded?(news)
            case .failure(let error): self?.handleErrors(error)
            }
        }
    }
    
    private func handleErrors(_ error: NewsError) {
        onFetchError?(error.description)
    }
}
