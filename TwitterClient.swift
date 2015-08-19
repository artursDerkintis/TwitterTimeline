//
//  TwitterClient.swift
//  TwitterTimeline
//
//  Created by Arturs Derkintis on 8/1/15.
//  Copyright © 2015 Starfly. All rights reserved.
//

import UIKit

let twitterConsumerKey = "Your Consumer Key Here"
let twitterConsumerSecret = "Your Consumer Secret Here"

let twitterBaseURL = NSURL(string: "https://api.twitter.com")


class TwitterClient: BDBOAuth1RequestOperationManager {
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance =  TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        return Static.instance
    }
    
    func postTweet(params: NSDictionary?, completion: (error: NSError?) -> () ){
        POST("1.1/statuses/update.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            print("posted tweet")
            completion(error: nil)
        }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            print("error tweeting")
            completion(error: error)
        }
    )}
    
    func favoriteTweet(id: Int, params: NSDictionary?, completion: (error: NSError?) -> () ){
        print("favoriteTweet called")
        print(id)
        POST("1.1/favorites/create.json?id=\(id)", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            print("favorited")
            completion(error: nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                print("error favoriting")
                completion(error: error)
            }
        )}

    
    func retweetTweet(id: Int, params: NSDictionary?, completion: (error: NSError?) -> () ){
        print("retweetTweet called")
        print(id)
        POST("1.1/statuses/retweet/\(id).json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            print("retweeted")
            completion(error: nil)
        }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                print("error retweeting")
                completion(error: error)
        }
    )}

    func homeTimelineWithCompletion(since_id : String?, count: String?, max_id : String?, completion: (tweets: [Tweet]?, error: NSError?) -> () ) {
        
        var url : String = "1.1/statuses/home_timeline.json?"
        if let since = since_id{
            url = url.stringByAppendingString(since)
        }
        if let coun = count{
            url = url.stringByAppendingString(coun)
        }
        if let max = max_id{
            url = url.stringByAppendingString(max)
        }
        url = url.substringToIndex(url.endIndex.predecessor())
        //Setting parameters to some NSDictionary will return absolutely nothing, so I customize url.
        
        GET(url, parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            //print("inside Timeline with Completion")
            let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            
            completion(tweets: tweets, error: nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                print("error getting home timeline")
                completion(tweets: nil, error: error)
        })

    }
   
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()){
        loginCompletion = completion
        
        // Fetch request token and redirect to authorization page
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "twitterClient://"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            print("Got the request token")
            let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
            UIApplication.sharedApplication().openURL(authURL!)
        }) { (error: NSError!) -> Void in
            print("Failed to get request token \(error.localizedDescription)")
            self.loginCompletion?(user: nil, error: error)
        }
    }
    
    func openURL(url: NSURL){
        TwitterClient.sharedInstance.fetchAccessTokenWithPath("oauth/access_token", method: "Post", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken: BDBOAuth1Credential!) -> Void in
            print("Got the access token!")
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                let user = User(dictionary: response as! NSDictionary)
                User.currentUser = user
                self.loginCompletion?(user: user, error: nil)
                }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                    print("error getting current user")
                    self.loginCompletion?(user: nil, error: error)
            })
                    }) { (error: NSError!) -> Void in
            print("Failed to receive access token")
            self.loginCompletion?(user: nil, error: error)
        }
    }

}
