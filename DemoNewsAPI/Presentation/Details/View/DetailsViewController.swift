//
//  DetailsViewController.swift
//  DemoNewsAPI
//
//  Created by KinWei on 2021/3/6.
//

import UIKit

class DetailsViewController: UIViewController {

    static func instantiate(viewModel: DetailsViewModel) -> DetailsViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "\(self)") as! DetailsViewController
        vc.viewModel = viewModel
        vc.bindViewModel()
        return vc
    }
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var desciptionLabel: UILabel!
    
    lazy var bufferedImageView: ProgressiveBufferedImageView = {
        let image = ProgressiveBufferedImageView(frame: .zero)
        image.translatesAutoresizingMaskIntoConstraints = false
        //image.backgroundColor = .blue
        return image
    }()
    
    var viewModel: DetailsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(bufferedImageView)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onViewWillAppear?()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layountConstraint()
    }

    func bindViewModel() {
        viewModel.startDisplay = { [weak self] new in
            DispatchQueue.main.async {
                self?.setupDisplay(of: new)
            }
        }
    }
}

private extension DetailsViewController {
    func setupDisplay(of new: DetailsNew) {
        dateLabel.text = new.date
        //topImageView.load(url: URL(string: new.imageUrl)!)//.downloaded(from: new.imageUrl, contentMode: .scaleToFill, placeholder: new.placeHolder)
        bufferedImageView.load(url: URL(string: new.imageUrl)!)
        titleLabel.text = new.title
        copyrightLabel.text = new.copyright
        desciptionLabel.text = new.description
    }
    
    func layountConstraint() {
        bufferedImageView.topAnchor.constraint(equalTo: topImageView.topAnchor).isActive = true
        bufferedImageView.leadingAnchor.constraint(equalTo: topImageView.leadingAnchor).isActive = true
        bufferedImageView.trailingAnchor.constraint(equalTo: topImageView.trailingAnchor).isActive = true
        bufferedImageView.bottomAnchor.constraint(equalTo: topImageView.bottomAnchor).isActive = true
        view.bringSubviewToFront(bufferedImageView)
    }
    
}
