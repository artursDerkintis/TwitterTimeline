//
//  SFSmartCollectionViewController.swift
//  TwitterTimeline
//
//  Created by Arturs Derkintis on 8/1/15.
//  Copyright © 2015 Starfly. All rights reserved.
//

import UIKit
import Twitter
import Accounts


let dateFormater = NSDateFormatter()

class SFSmartCollectionController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var collectionView : UICollectionView?
    var tweets = [Tweet]()
    var timer : NSTimer?
    var sizzingCell : SFTweetCell?
    var currentCellIndexPath : NSIndexPath? = NSIndexPath(forRow: 0, inSection: 0)
    ///Temporary
    var userNames = NSMutableArray()
    var arrayOfTweets = NSArray()
    var bottomButton : UIButton?
    var refresh : UIRefreshControl?
    var activity : UIActivityIndicatorView?
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = -1
        layout.itemSize = CGSize(width: 600, height: 150)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView?.registerClass(SFTweetCell.self, forCellWithReuseIdentifier: "tweet")
        sizzingCell = SFTweetCell(frame: CGRect(x: 0, y: 0, width: 600, height: 80))
 
        sizzingCell?.accessibilityIdentifier = "SizeCell"
        collectionView?.delegate = self
        collectionView?.decelerationRate = 1.0
        collectionView?.backgroundColor = UIColor.clearColor()
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 50, right: 0)
        collectionView?.dataSource = self
        collectionView?.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        refresh = UIRefreshControl(frame: collectionView!.bounds)
        refresh?.addTarget(self, action: "refreshColl", forControlEvents: UIControlEvents.ValueChanged)
  
        collectionView?.insertSubview(refresh!, atIndex: 0)
        bottomButton = UIButton(type: UIButtonType.System)
        bottomButton!.tintColor = UIColor.lightGrayColor()
        bottomButton!.setTitle("Load more tweets", forState: UIControlState.Normal)
        bottomButton!.autoresizingMask = [UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleWidth]
        bottomButton!.frame = CGRect(x: 0, y: collectionView!.frame.height - 50, width: collectionView!.frame.width, height: 50)
      
        bottomButton!.hidden = true
        bottomButton!.addTarget(self, action: "appendBottomItems", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(collectionView!)
        view.addSubview(bottomButton!)
        onStartLoadTweets()
        timer = NSTimer.scheduledTimerWithTimeInterval(200, target: self, selector: "refreshCollection", userInfo: nil, repeats: true)
    }
    func onStartLoadTweets(){
        let since : Int = NSUserDefaults.standardUserDefaults().integerForKey("MaxID")
        let currentID : Int = NSUserDefaults.standardUserDefaults().integerForKey("currentID")
        
        TwitterClient.sharedInstance.homeTimelineWithCompletion(since != 0 ? "since_id=\(String(since))&" : nil, count: "count=50&", max_id: nil) { (tweets, error) -> () in
                
                /// print(tweets)
                //print("\(error?.localizedDescription)")
            if tweets != nil{
                self.tweets += tweets!
                self.collectionView?.reloadData()
                NSUserDefaults.standardUserDefaults().setInteger(self.tweets[0].id!, forKey: "latestID")
                for tw in self.tweets{
                    if currentID == tw.id!{
                        self.collectionView!.scrollToItemAtIndexPath(NSIndexPath(forRow: self.tweets.indexOf(tw)!, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
                    }
                }
            }
            

        
        }
    }
    func refreshCollection(){
        let since : Int = NSUserDefaults.standardUserDefaults().integerForKey("latestID")
        
        print("ID \(since)")
        
        TwitterClient.sharedInstance.homeTimelineWithCompletion(since != 0 ? "since_id=\(String(since))&" : nil, count: "count=200&", max_id: nil) { (tweets, error) -> () in
            
            /// print(tweets)
            //print("\(error?.localizedDescription)")
            if tweets != nil{
                if tweets?.count != 0{
                    var id : Int?
                    var midCell : UICollectionViewCell?
                    let mid = self.collectionView!.indexPathForItemAtPoint(CGPointMake(self.collectionView!.frame.width * 0.5 + self.collectionView!.contentOffset.x, self.collectionView!.frame.height * 0.1 + self.collectionView!.contentOffset.y))
                    
                    let midCel = self.collectionView!.indexPathForItemAtPoint(CGPointMake(self.collectionView!.frame.width * 0.5 + self.collectionView!.contentOffset.x, self.collectionView!.frame.height * 0.7 + self.collectionView!.contentOffset.y))
                    if let m = mid{
                        midCell = self.collectionView!.cellForItemAtIndexPath(m)
                    }else if let m = midCel{
                        midCell = self.collectionView!.cellForItemAtIndexPath(m)
                    }
                    id = (midCell as! SFTweetCell).id!
                var tw = tweets
                if tw != nil{
                tw! += self.tweets
                }else{
                    tw = self.tweets
                }
                self.tweets = tw!
                NSUserDefaults.standardUserDefaults().setInteger(self.tweets[0].id!, forKey: "latestID")
                 
                
                self.collectionView!.reloadData()
                    
                for tws in self.tweets{
                    if id == tws.id{
                    self.collectionView!.scrollToItemAtIndexPath(NSIndexPath(forRow: self.tweets.indexOf(tws)!, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
                }}
 
                    
                                    self.refresh?.endRefreshing()
                }else{
                self.refresh?.endRefreshing()
                }
            }
            
            
            
        }

    }
    func appendBottomItems(){
        if activity == nil{
        activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activity?.color = UIColor.lightGrayColor()
        activity?.center = CGPoint(x: bottomButton!.frame.width * 0.5, y: bottomButton!.frame.height * 0.5)
        bottomButton!.setTitle(" ", forState: UIControlState.Normal)
        bottomButton?.addSubview(activity!)
            
            activity?.hidesWhenStopped = true
           
        }
            activity?.startAnimating()
        let maxID : Int = NSUserDefaults.standardUserDefaults().integerForKey("MinID")
        TwitterClient.sharedInstance.homeTimelineWithCompletion(nil, count: "count=50&", max_id: maxID != 0 ? "max_id=\(String(maxID - 1))&" : nil) { (tweets, error) -> () in
            
            /// print(tweets)
            //print("\(error?.localizedDescription)")
            if tweets != nil{
                let mid = CGPointMake(self.collectionView!.frame.width * 0.5 + self.collectionView!.contentOffset.x, self.collectionView!.frame.height * 0.1 + self.collectionView!.contentOffset.y)
                let count = self.tweets.count
                self.tweets += tweets!
                var indexPaths = [NSIndexPath]()
                for i in count.stride(to: self.tweets.count, by: +1){
                    
                    indexPaths.append(NSIndexPath(forRow: i, inSection: 0))
                }
                NSUserDefaults.standardUserDefaults().setInteger(self.tweets[0].id!, forKey: "latestID")
                self.collectionView!.insertItemsAtIndexPaths(indexPaths)
              
                        
                self.collectionView!.scrollToItemAtIndexPath(self.collectionView!.indexPathForItemAtPoint(mid)!, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
                
                self.activity?.stopAnimating()
                self.bottomButton?.setTitle("Load more tweets", forState: UIControlState.Normal)
                self.bottomButton?.hidden = true
            }
            
            
            
        }
        
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if tweets.count > 0{
        let cell = collectionView!.visibleCells().first as? SFTweetCell
            if cell != nil{
        NSUserDefaults.standardUserDefaults().setInteger(cell!.id!, forKey: "currentID")
            let index = collectionView?.indexPathForCell(cell!)!.row
            let ind = min(self.tweets.count - 1, index! + 30)
            
        NSUserDefaults.standardUserDefaults().setInteger(self.tweets[ind].id!, forKey: "MaxID")
        
        let lastID = (tweets[tweets.count - 1] as Tweet).id!
        NSUserDefaults.standardUserDefaults().setInteger(lastID, forKey: "MinID")
            }
        }
        let contentHeight = self.collectionView!.contentSize.height
        if  self.collectionView!.contentOffset.y > (contentHeight - self.collectionView!.frame.height){
            
            bottomButton?.hidden = false
        }else{
            bottomButton?.hidden = true
        }
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("tweet", forIndexPath: indexPath) as! SFTweetCell
        updateCell(withCell: cell, indexPath: indexPath)
        return cell
        
    }
    
    func updateCell(withCell cell : SFTweetCell, indexPath : NSIndexPath){
        let status = tweets[indexPath.row]
        
        if cell.accessibilityIdentifier != "SizeCell"{
            cell.profileLabel?.attributedText = status.wholeUserName!
            cell.setImageWithURL(status.user!.profileImageURL!)
            if status.extendedE != nil{
                cell.refreshImages(status.extendedE!.imagesURLS)
                cell.playGif(status.extendedE!.video, aspectRatioo: status.extendedE!.aspectRatio)
            }else{
                cell.refreshImages([])
                cell.playGif("", aspectRatioo: [16, 9])
            }
            cell.time?.createdAtString = status.createdAtString
            dateFormater.dateFormat = "EEE MMM d HH:mm:ss Z y"
            cell.time?.label?.text = dateFormater.dateFromString(status.createdAtString!)?.timeAgoSimple
            //print("\(status.text)\(status.favorited)")
            //print("\(status.text)\(status.retweeted)")
            cell.id = status.id
            if status.retweet_count != 0{
                cell.buttons[0].setTitle(abbreviateNumber(NSNumber(integer: status.retweet_count! )) as String, forState: UIControlState.Normal)
                cell.buttons[0].tintColor = status.retweeted! ? UIColor(rgba: "#02ffbc") : UIColor.lightGrayColor()
            }else{
                cell.buttons[0].setTitle("", forState: UIControlState.Normal)
                 cell.buttons[0].tintColor = status.favorited! ? UIColor(rgba: "#ffd000") : UIColor.lightGrayColor()
            }
            if status.favorite_count != 0{
                cell.buttons[1].setTitle(abbreviateNumber(NSNumber(integer: status.favorite_count! )) as String, forState: UIControlState.Normal)
                cell.buttons[1].tintColor = status.favorited! ? UIColor(rgba: "#ffd000") : UIColor.lightGrayColor()
            }else{
                cell.buttons[1].setTitle("", forState: UIControlState.Normal)
                 cell.buttons[1].tintColor = status.favorited! ? UIColor(rgba: "#ffd000") : UIColor.lightGrayColor()
            }
            cell.overlay?.backgroundColor = status.user?.themeColor
            cell.profileImageView?.layer.borderColor = status.user?.themeColor!.CGColor
            cell.layer.borderColor = status.user?.themeColor!.colorWithAlphaComponent(0.2).CGColor
            
                //"'PAC-MAN 256' Gameplay and Special @CrossyRoad Update Coming Soon http://t.co/5EEfINCYgy #gamedev "
        }else{
            if status.extendedE != nil{
                if status.extendedE!.imagesURLS.count > 0{
                    cell.fakeImage(on: true)
                }else{
                    cell.fakeImage(on: false)
                }
                if status.extendedE!.video != ""{
                    cell.fakeGifPlayer(on: true, aspectRatioo: status.extendedE!.aspectRatio)
                }else{
                    cell.fakeGifPlayer(on: false, aspectRatioo: status.extendedE!.aspectRatio)
                }
            }else{
                cell.fakeImage(on: false)
                cell.fakeGifPlayer(on: false, aspectRatioo: [16, 9])
            }
        }
        if status.extendedE != nil{
        for url in status.extendedE!.urlsToExclude{
            status.text = status.text?.stringByReplacingOccurrencesOfString(url, withString: "")
            }}
        cell.tweetTextView?.text = status.text
        
        cell.resize()

        
        
        
        
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        

    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        updateCell(withCell: sizzingCell!, indexPath: indexPath)
        return sizzingCell!.frame.size
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        }



}
