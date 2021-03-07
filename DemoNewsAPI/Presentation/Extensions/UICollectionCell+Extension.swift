//
//  UICollectionCell+Extension.swift
//  DemoNewsAPI
//
//  Created by KinWei on 2021/3/7.
//

import UIKit

extension UICollectionViewCell {
    static var identifierName: String {
        return String(describing: type(of: self))
    }
}
