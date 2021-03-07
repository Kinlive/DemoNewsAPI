//
//  DetailsViewModel.swift
//  DemoNewsAPI
//
//  Created by KinWei on 2021/3/6.
//

import UIKit

struct DetailsNew {
    let date: String
    let title: String
    let imageUrl: String
    let placeHolder: UIImage
    let copyright: String
    let description: String
}

protocol DetailsViewModelInput {
    var onViewWillAppear: (() -> Void)? { get }
}
protocol DetailsViewModelOutput {
    var startDisplay: ((DetailsNew) -> Void)? { get set }
}
protocol DetailsViewModel: DetailsViewModelOutput, DetailsViewModelInput {
    
}

final class DefaultDetailsViewModel: DetailsViewModel {
    // MARK: - Inputs
    var onViewWillAppear: (() -> Void)?

    // MARK: - outputs
    var startDisplay: ((DetailsNew) -> Void)?
    
    private let passValue: New
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd" // to yyyy MMM. dd
        return formatter
    }()
    
    private let imageCacher = CacheManager.shared.imageCache
    
    init(passValue: New) {
        self.passValue = passValue
        
        onViewWillAppear = { [weak self] in
            self?.transformData()
        }
    }
    
}

private extension DefaultDetailsViewModel {
    func transformData() {
        
        var displayDate: String = passValue.date
        if let date = dateFormatter.date(from: passValue.date) {
            dateFormatter.dateFormat = "yyyy MMM. dd"
            displayDate = dateFormatter.string(from: date)
        }
        
        var placeholderImage: UIImage
        if let image = imageCacher.value(forKey: passValue.url) {
            placeholderImage = image
        } else {
            placeholderImage = UIImage(named: "placeholder")!
        }
        
        let newOne = DetailsNew(
            date: displayDate,
            title: passValue.title,
            imageUrl: passValue.hdurl,
            placeHolder: placeholderImage,
            copyright: passValue.copyright,
            description: passValue.description)
        
        startDisplay?(newOne)
    }
}
