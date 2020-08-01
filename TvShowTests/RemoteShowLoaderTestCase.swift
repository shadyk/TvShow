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
        let (sut,client) = makeSUT(url: anyURL())

        var errors = [RemoteShowLoader.Error]()

        sut.load(){ error in
            if error != nil {
                errors.append(error!)
            }
        }

        client.complete(with: NSError())

        XCTAssertEqual(errors,[.connectivity])
    }

    func test_load_completesWithNoErrorOnClient(){
        let (sut,client) = makeSUT(url: anyURL())

        var errors = [RemoteShowLoader.Error]()

        sut.load(){ error in
            if error != nil {
                errors.append(error!)
            }
        }

        client.complete(with: nil)

        XCTAssertEqual(errors,[])
    }

    //MARK:- helpers

    //MAKE SUT
    private func makeSUT(url:URL) -> (RemoteShowLoader, HTTPClientSpy) {

        let client = HTTPClientSpy()
        let remoteShowLoader = RemoteShowLoader(url: url, client: client)
        return (remoteShowLoader,client)
    }

    //CLEINT SPY
    private class HTTPClientSpy: HTTPClient{
        var messages = [(url:URL,completion:(Error?)->Void)]()
        var requestedURLs : [URL]  {
            return messages.map{$0.url}
        }

        func get(url: URL, completion: @escaping (Error?) -> Void) {
            messages.append((url:url,completion:completion))
        }

        func complete(with error: Error?, at index:Int = 0){
            messages[index].completion(error)
        }
    }


    //HELPER
    private func anyURL() -> URL{
        return URL(string:"http://any-url.com")!
    }

}
