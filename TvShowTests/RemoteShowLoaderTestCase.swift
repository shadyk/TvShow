//
//  RemoteShowLoader.swift
//  TvShowsTests
//
//  Created by Shady Kahaleh on 7/26/20.
//

import XCTest
@testable import TvShows

protocol HTTPClient{
    func get(url:URL)
}

protocol ShowLoader{
    func load()
}

class RemoteShowLoader : ShowLoader{
    let url : URL
    let client : HTTPClient

    init(url:URL, client:HTTPClient) {
        self.url = url
        self.client = client
    }

    func load() {
        client.get(url: url)
    }


}
class RemoteShowLoaderTestCase: XCTestCase {

    func test_init_doesntLoadWhenCreated(){
        let (_,client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    func test_load_whenURLCalled(){
        let url = anyURL()
        let (remoteLoader,client) = makeSUT(url: url)
        remoteLoader.load()
        XCTAssertEqual(client.requestedURLs,[url])

    }

    func test_load_twice(){
        let url = anyURL()
        let (remoteLoader,client) = makeSUT(url: url)
        remoteLoader.load()
        remoteLoader.load()
        XCTAssertEqual(client.requestedURLs,[url,url])
    }


//MARK:- helpers
    private func makeSUT(url:URL = URL(string:"http://any-url.com")!) -> (RemoteShowLoader, HTTPClientSpy) {

        let client = HTTPClientSpy()
        let remoteShowLoader = RemoteShowLoader(url: url, client: client)

        return (remoteShowLoader,client)
    }

    private func anyURL() -> URL{
        return URL(string:"http://any-url.com")!
    }

    private class  HTTPClientSpy: HTTPClient{

        init(){

        }
        var requestedURLs = [URL]()

        func get(url:URL) {
            requestedURLs.append(url)
        }


    }
}
