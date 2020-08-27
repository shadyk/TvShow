//
//  ShowLoader.swift
//  TvShows
//
//  Created by Shady Kahaleh on 8/17/20.
//

import Foundation


public enum ShowLoaderResult {
    case success(Show?)
    case failure(Error)
}

public protocol ShowLoader{
//    typealias Result = Swift.Result<[Show], Error>


    func load(completion:@escaping (ShowLoaderResult) -> Void)
}
