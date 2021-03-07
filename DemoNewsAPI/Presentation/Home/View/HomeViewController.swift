//
//  HomeViewController.swift
//  DemoNewsAPI
//
//  Created by KinWei on 2021/3/6.
//

import UIKit

class HomeViewController: UIViewController {

    
    @IBOutlet weak var startButton: UIButton!
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.tintColor = .blue
        return indicator
    }()
    
    let viewModel = DefaultHomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        addSubview()
        bindViewModel()
        
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutConstraint()
    }
    
    @IBAction func nextPage(_ sender: UIButton) {
        viewModel.onStartFetch?()
    }
    
    func bindViewModel() {
        viewModel.onFetchError = { error in
            print(error)
        }
        
        viewModel.onNewsLoaded = { [weak self] news in
            self?.displayListPage(with: news)
        }
        
        viewModel.isLoading = { [weak self] loading in
            self?.indicatorStateOnLoading(loading)
        }
    }
    
}

private extension HomeViewController {
    func addSubview() {
        view.addSubview(loadingIndicator)
    }
    
    func layoutConstraint() {
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
    }
    
    func indicatorStateOnLoading(_ loading: Bool) {
        DispatchQueue.main.async {
            self.startButton.isEnabled = !loading
            loading ? self.loadingIndicator.startAnimating() : self.loadingIndicator.stopAnimating()
        }
    }
    
    func displayListPage(with news: News) {
        let viewModel = DefaultListViewModel(passValue: news)
        DispatchQueue.main.async {
            let vc = ListViewController.instantiate(viewModel: viewModel)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
