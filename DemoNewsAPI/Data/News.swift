//
//  News.swift
//  DemoNewsAPI
//
//  Created by KinWei on 2021/3/6.
//

import Foundation

struct New: Codable {
    let welcomeDescription, copyright, title: String
    let url: String
    let apodSite: String
    let date, mediaType: String
    let hdurl: String

    enum CodingKeys: String, CodingKey {
        case welcomeDescription = "description"
        case copyright, title, url
        case apodSite = "apod_site"
        case date
        case mediaType = "media_type"
        case hdurl
    }
}

typealias News = [New]
