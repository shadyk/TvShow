//
//  RemoteShowLoader.swift
//  TvShows
//
//  Created by Shady Kahaleh on 7/31/20.
//

import Foundation
public protocol HTTPClient{
    func get(url:URL)
}

protocol ShowLoader{
    func load(completion:(Error) -> Void)
}

public final class RemoteShowLoader : ShowLoader{
    private let url : URL
    private let client : HTTPClient

    public init(url:URL, client:HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion:(Error)->Void) {
        client.get(url: url)
    }
}
