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
        
        viewModel.onNewsLoaded = { news in
            print("success for datas: \n\(news.count)")
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
        loadingIndicator.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
    }
    
    func indicatorStateOnLoading(_ loading: Bool) {
        DispatchQueue.main.async {
            self.startButton.isEnabled = !loading
            loading ? self.loadingIndicator.startAnimating() : self.loadingIndicator.stopAnimating()
        }
    }
}
