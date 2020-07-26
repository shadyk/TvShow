//
//  RemoteShowLoader.swift
//  TvShowsTests
//
//  Created by Shady Kahaleh on 7/26/20.
//

import XCTest
@testable import TvShows

class HTTPClient{
    var url : URL?
    init(url:URL){
        self.url = url
    }
}

class RemoteShowLoader{


}
class RemoteShowLoaderTestCase: XCTestCase {

    func test_init_doesntLoadWhenCreated(){
        let sut = makeSUT()
        let remoteLoader = sut.0



    }
//MARK:- helpers
    func makeSUT() -> (RemoteShowLoader, HTTPClient) {
        let client = HTTPClient(url: anyURL())
        let remoteShowLoader = RemoteShowLoader()

        return (remoteShowLoader,client)
    }

    func anyURL() -> URL{
        return URL(string:"http://any-url.com")!
    }
}
