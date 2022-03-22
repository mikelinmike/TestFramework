//
//  MikeTestFramwork.swift
//  TestFramework
//
//  Created by wondercise on 2022/3/22.
//

import Foundation

open class MikeTest1Framework{
    
    open func test1(){
        print("MikeTest1Framework_test1")
    }
    
    public func test2(){
        print("MikeTest1Framework_test2")
    }
    
    internal func test3(){
        print("MikeTest1Framework_test3")
    }
}


public class MikeTest2Framework{
    open func test1(){
        print("MikeTest2Framework_test1")
    }
    
    public func test2(){
        print("MikeTest2Framework_test2")
    }
    
    internal func test3(){
        print("MikeTest2Framework_test3")
    }
}
