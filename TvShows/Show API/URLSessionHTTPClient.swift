//
//  Created by Shady
//  All rights reserved.
//  

import Foundation

public class URLSessionHTTPClient : HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    struct UnexpectedValueRepresentaiton : Error {}
    
    public func get(url: URL,headers:[String:String]? = nil, completion: @escaping (HttpClientResult) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let headers = headers {
            request.allHTTPHeaderFields = headers
        }

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data, let response = response as? HTTPURLResponse{
                completion(.success(data, response))
            }
            else{
                completion(.failure(UnexpectedValueRepresentaiton()))
            }
        }.resume()
    }

}


//class CustomUrlSessionDelegate : NSObject, URLSessionDelegate{
//
//    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
//                   // First load our extra root-CAs to be trusted from the app bundle.
//                   let trust = challenge.protectionSpace.serverTrust
//
//                   let rootCa = "fullchain"
//                   if let rootCaPath = Bundle.main.path(forResource: rootCa, ofType: "pem") {
//                       if let rootCaData = NSData(contentsOfFile: rootCaPath) {
//
//                           let rootCert = SecCertificateCreateWithData(nil, rootCaData)!
//
//                           SecTrustSetAnchorCertificates(trust!, [rootCert] as CFArray)
//
//                           SecTrustSetAnchorCertificatesOnly(trust!, false)
//                       }
//                   }
//            var cferror : CFError!
//            let trustResult = SecTrustEvaluateWithError(trust!, &cferror)
//
//                   if (trustResult) {
//                       // Trust certificate.
//
//                       let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
//                       challenge.sender?.use(credential, for: challenge)
//
//                   } else {
//                       NSLog("Invalid server certificate.")
//                       challenge.sender?.cancel(challenge)
//                   }
//               } else {
//                   NSLog("Got unexpected authentication method \(challenge.protectionSpace.authenticationMethod)");
//                   challenge.sender?.cancel(challenge)
//               }
//           }
//}
