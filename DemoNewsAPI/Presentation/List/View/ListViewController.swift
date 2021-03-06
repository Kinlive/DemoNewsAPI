//
//  ListViewController.swift
//  DemoNewsAPI
//
//  Created by KinWei on 2021/3/6.
//

import UIKit

class ListViewController: UIViewController {
    
    static func instantiate(viewModel: ListViewModel) -> ListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(identifier: "\(self)") as! ListViewController
        vc.viewModel = viewModel
        vc.bindViewModel()
        return vc
        
    }

    @IBOutlet weak var listCollectionView: UICollectionView!
    
    private let cellXSpacing: CGFloat = 2
    private let cellYSpacing: CGFloat = 3
    private let lineCount: CGFloat = 4
    
    var viewModel: ListViewModel!
    var displayNews: News = [] {
        didSet {
            DispatchQueue.main.async {
                self.listCollectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onViewWillAppear?()
    }
    
}

private extension ListViewController {
    func configure() {
        title = "List"
        listCollectionView.register(ListCell.self, forCellWithReuseIdentifier: ListCell.identifierName)
        listCollectionView.delegate = self
        listCollectionView.dataSource = self
    }
    
    func bindViewModel() {
        viewModel.displayDetail = { [weak self] new in
            self?.toNextPage(with: new)
        }
        
        viewModel.displayNews = { [weak self] news in
            self?.displayNews = news
        }
        
        viewModel.numberState = { [weak self] (current, total) in
            self?.title = "List (\(current)/\(total))"
        }
        
        viewModel.onImageDownloaded = { [weak self] index in
            DispatchQueue.main.async {
                self?.listCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }
    }
    
    func toNextPage(with value: New) {
        let viewModel = DefaultDetailsViewModel(passValue: value)
        DispatchQueue.main.async {
            let vc = DetailsViewController.instantiate(viewModel: viewModel)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.width - (lineCount * cellXSpacing)) / lineCount
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellYSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellXSpacing
    }
}

extension ListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return displayNews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCell.identifierName, for: indexPath) as? ListCell else { return UICollectionViewCell() }
        let new = displayNews[indexPath.row]
        let task = viewModel.onCellForRow?(indexPath.row)
        cell.configure(by: new, image: task?.image ?? UIImage(named: "placeholder"))
        
        return cell
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.onSelected?(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.onCellWillDisplay?(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.onCellDidEndDisplay?(indexPath)
    }
}

extension ListViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard displayNews.count > 0 else { return }
        let offsetY = scrollView.contentOffset.y
        
        let bottomEdge = (offsetY + listCollectionView.frame.height)
        guard bottomEdge >= (listCollectionView.contentSize.height + 100) else { return }
        viewModel.onScrollToBottom?()
    }
}
