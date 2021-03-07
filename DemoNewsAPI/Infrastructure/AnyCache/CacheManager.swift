//
//  CacheManager.swift
//  MessageDemo
//
//  Created by Cheryl Chen on 2020/2/14.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class CacheManager: NSObject {
    public static let shared: CacheManager = CacheManager()

    public private(set) var imageCache = Cache<String, UIImage>()
    
    func clearCache() {
        imageCache.removeAllValue()
    }
}
