//
//  RemoteShowLoader.swift
//  TvShowsTests
//
//  Created by Shady Kahaleh on 7/26/20.
//

import XCTest
import TvShows

class RemoteShowLoaderTestCase: XCTestCase {

    func test_init_doesntLoadWhenCreated(){
        let (_,client) = makeSUT(url: anyURL())
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

    func test_load_deliversErrorOnClient(){
        let url = anyURL()
        let (remoteLoader,client) = makeSUT(url: url)

        var errors = [RemoteShowLoader.Error]()
        remoteLoader.load(){ error in
            if error != nil {
                errors.append(error!)
            }
        }

        XCTAssertEqual(errors,[.connectivity])
    }


    //MARK:- helpers
    private func makeSUT(url:URL) -> (RemoteShowLoader, HTTPClientSpy) {

        let client = HTTPClientSpy()
        let remoteShowLoader = RemoteShowLoader(url: url, client: client)
        return (remoteShowLoader,client)
    }

    private func anyURL() -> URL{
        return URL(string:"http://any-url.com")!
    }

    private class HTTPClientSpy: HTTPClient{

        var requestedURLs = [URL]()

        func get(url: URL, completion: @escaping (Error?) -> Void) {

            completion(RemoteShowLoader.Error.connectivity)
            requestedURLs.append(url)
        }
    }
}
