//
//  Util.swift
//  PureMVCSwift Demo
//
//  Created by Stephan Schulz on 07.10.14.
//  Copyright (c) 2014 Stephan Schulz. All rights reserved.
//

import Foundation

typealias dispatch_cancelable_closure = (cancel : Bool) -> ()

func delay(_ time:TimeInterval, closure:()->()) ->  dispatch_cancelable_closure?
{
    
    func dispatch_later(_ clsr:()->())
    {
        let interval = DispatchTimeInterval.milliseconds(Int(time * 1000))
        DispatchQueue.main.after(
            when: DispatchTime.now() + interval, execute: clsr)
    }
    
    var closure:(() -> Void)? = closure
    var cancelableClosure:dispatch_cancelable_closure?
    
    let delayedClosure:dispatch_cancelable_closure = { cancel in
        if let clsr = closure
        {
            if (cancel == false)
            {
                DispatchQueue.main.async(execute: clsr);
            }
        }
        closure = nil
        cancelableClosure = nil
    }
    
    cancelableClosure = delayedClosure
    
    dispatch_later
        {
            if let delayedClosure = cancelableClosure
            {
                delayedClosure(cancel: false)
            }
    }
    
    return cancelableClosure;
    
}
