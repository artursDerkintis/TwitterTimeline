//
//  ExtendedEntitie.swift
//  TwitterTimeline
//
//  Created by Arturs Derkintis on 8/5/15.
//  Copyright © 2015 Starfly. All rights reserved.
//

import UIKit

class ExtendedEntitie : NSObject {
    var media : NSArray?
    var urlsToExclude = [String]()
    var imagesURLS = [String]()
    var aspectRatio = [Int]()
    var video : String = ""
    
    init(dictionary : NSDictionary){
        media = dictionary["media"] as? NSArray
        if let mediaArray = media{
            for item in mediaArray as! [NSDictionary]{
                let type = item["type"] as! String
                let url = item["url"] as! String
                urlsToExclude.append(url)
                if type == "photo"{
                    imagesURLS.append(item["media_url"] as! String)
                }else if type == "animated_gif" || type == "video"{
                    
                    let videoInfo = item["video_info"] as? NSDictionary
                    let wRate = (videoInfo!["aspect_ratio"] as! NSArray)[0] as! Int
                    let hRate = (videoInfo!["aspect_ratio"] as! NSArray)[1] as! Int
                    aspectRatio = [wRate, hRate]
                    let variants = videoInfo!["variants"] as? NSArray
                    if variants?.count > 0{
                        for firstItem in variants as! [NSDictionary]{
                            
                            if (firstItem["content_type"] as! String) == "video/mp4"{
                                video = firstItem["url"] as! String
                                
                                
                            }
                        }
                        
                    }
                    
                    
                }
            }
        }
    }
}
