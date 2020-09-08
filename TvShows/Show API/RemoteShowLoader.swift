//
//  RemoteShowLoader.swift
//  TvShows
//
//  Created by Shady Kahaleh on 7/31/20.
//

import Foundation

public final class RemoteShowLoader : ShowLoader {
    private let url : URL
    private let headers : [String:String]?
    private let client : HTTPClient

    public enum Error : Swift.Error {
        case connectivity
        case invalidData
        case notFound
    }

    public typealias Result = ShowLoaderResult

    public init(url:URL, headers:[String:String]?, client:HTTPClient) {
        self.url = url
        self.client = client
        self.headers = headers
    }

    public func load(completion:@escaping (Result) -> Void) {
        client.get(url: url, headers: headers){ [weak self] result in
            guard self != nil else { return}
            switch result {
            case let .success(data,response):
                completion(RemoteShowMapper.map(data: data, response:response))
            case .failure:
                completion(.failure(RemoteShowLoader.Error.connectivity))
            }
        }
    }
}





