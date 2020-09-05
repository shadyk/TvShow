//
//  Created by Shady
//  All rights reserved.
//  

import XCTest

extension XCTestCase {

  func trackForMemoryLeak(_ instance:AnyObject,file: StaticString = #file, line: UInt = #line){
       addTeardownBlock {[weak instance] in
           XCTAssertNil(instance,"instance Should deallocate after using. Potenial memory leak",file: file,line: line)
       }
   }


}