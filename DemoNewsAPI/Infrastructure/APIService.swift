//
//  APIService.swift
//  DemoNewsAPI
//
//  Created by KinWei on 2021/3/7.
//

import Foundation

enum NewsError: Error {
    case urlNotFound
    case dataNotFound
    case dataTransferFail(String)
    case somethingWrong(String)
    case statusCode(String)
    case foundNil
    
    var description: String {
        switch self {
        case .urlNotFound: return "url not found"
        case .dataNotFound: return "data not found"
        case .dataTransferFail(let text): return "data transfer fail: \(text)"
        case .somethingWrong(let text): return "somthing went wrong: \(text)"
        case .statusCode(let text): return text
        case .foundNil: return "Found nil"
        }
    }
}

typealias NewsResult = Result<News, NewsError>

final class APIService {
    
    static let shared = APIService()
    
    let session: URLSession = URLSession.shared
    
    private let newsUrl: URL = URL(string: "https://raw.githubusercontent.com/cmmobile/NasaDataSet/main/apod.json")!
    
    private let decoder = JSONDecoder()
    
    
    func request(completionHandler: @escaping (NewsResult) -> Void) {
    
        session.dataTask(with: getRequest()) { [weak self] (data, response, error) in
            guard let `self` = self else { completionHandler(.failure(.foundNil)); return }
            
            if let error = error {
                completionHandler(.failure(.somethingWrong(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completionHandler(.failure(.statusCode("status code not equal to 200")))
                return
            }
            
            guard let data = data else { completionHandler(.failure(.dataNotFound)); return }
            completionHandler(self.transferToNews(data: data))
        }
        .resume()
    }
}

private extension APIService {
    private func transferToNews(data: Data) -> NewsResult {
        do {
            let news = try decoder.decode(News.self, from: data)
            return .success(news)
            
        } catch let error {
            return .failure(.dataTransferFail(error.localizedDescription))
        }
    }
    
    private func getRequest() -> URLRequest {
        var request = URLRequest(url: newsUrl)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
