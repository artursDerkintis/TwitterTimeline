//
//  Extenstions.swift
//  TwitterTimeline
//
//  Created by Arturs Derkintis on 8/10/15.
//  Copyright © 2015 Starfly. All rights reserved.
//

import Foundation
import UIKit

extension UIColor{
    convenience init(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index   = rgba.startIndex.advancedBy(1)
            let hex : NSString    = rgba.substringFromIndex(index)
            let scanner = NSScanner(string: hex as String)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                if (hex.length == 6) {
                    red   = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)  / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF) / 255.0
                } else if hex.length == 8 {
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                } else {
                    print("invalid rgb string, length should be 7 or 9", terminator: "")
                }
            } else {
                print("scan hex error")
            }
        } else {
            print("invalid rgb string, missing '#' as prefix", terminator: "")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
}
public func abbreviateNumber(num: NSNumber) -> NSString {
    var ret: NSString = ""
    let abbrve: [String] = ["K", "M", "B"]
    
    let floatNum = num.floatValue
    
    if floatNum > 1000 {
        
        for i in 0..<abbrve.count {
            let size = pow(10.0, (Float(i) + 1.0) * 3.0)
            // print("\(size)   \(floatNum)")
            if (size <= floatNum) {
                let num = floatNum / size
                let str = floatToString(num)
                ret = NSString(format: "%@%@", str, abbrve[i])
            }
        }
    } else {
        ret = NSString(format: "%d", Int(floatNum))
    }
    
    return ret
}
public func floatToString(val: Float) -> NSString {
    var ret = NSString(format: "%.1f", val)
    var c = ret.characterAtIndex(ret.length - 1)
    
    while c == 48 {
        ret = ret.substringToIndex(ret.length - 1)
        c = ret.characterAtIndex(ret.length - 1)
        
        
        if (c == 46) {
            ret = ret.substringToIndex(ret.length - 1)
        }
    }
    return ret
}
