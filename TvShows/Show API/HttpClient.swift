//
//  HttpClient.swift
//  TvShows
//
//  Created by Shady Kahaleh on 8/16/20.
//

import Foundation

public enum HttpClientResult {
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient{

    func get(url:URL, completion: @escaping(HttpClientResult) -> Void)
}
