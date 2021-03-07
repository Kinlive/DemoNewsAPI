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
    
    
    var viewModel: DetailsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onViewWillAppear?()
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
        topImageView.downloaded(from: new.imageUrl, contentMode: .scaleToFill, placeholder: new.placeHolder)
        titleLabel.text = new.title
        copyrightLabel.text = new.copyright
        desciptionLabel.text = new.description
    }
}
