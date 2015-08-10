//
//  SFScrollView.swift
//  TwitterTimeline
//
//  Created by Arturs Derkintis on 7/14/15.
//  Copyright © 2015 Neal Ceffrey. All rights reserved.
//
/*

*/
import UIKit

//Scrolling orientation
enum SFOrienation{
    case horizontal; //Default
    case vertical;
}

enum SFCellSizeStyle{
    case fixed;     //Fixed size to all cells
    case custom;      //Set costom size for each cell
   
}

let cellColor = UIColor.orangeColor()
let cellBorderColor = UIColor.lightGrayColor()



@IBDesignable
class SFScrollView : UIView, UIScrollViewDelegate {
    var containsSomething : Bool = false
    //Array of Cells
    var cells = NSMutableArray()
    
    @IBInspectable var offsetGap : CGFloat? = 10
    
    @IBInspectable var fixedCellSize : CGSize? = CGSize(width: 100, height: 50)
    
    
    var orienation = SFOrienation.horizontal
    var cellSizeStyle = SFCellSizeStyle.fixed

    
    var scrollView : UIScrollView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clearColor()
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        scrollView?.autoresizingMask = sfMaskBoth
        
        ///Delete this if you don't need it
        scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.showsVerticalScrollIndicator = false
        ////
        scrollView!.layer.masksToBounds = true
        scrollView!.layer.cornerRadius = 10
        addSubview(scrollView!)
        scrollView?.delegate = self
       
    }

    func setUp(cellSizeStyle : SFCellSizeStyle, orien : SFOrienation, cellContentArray : [String]?){
        self.cellSizeStyle = cellSizeStyle
        self.orienation = orien
        
        for item in cellContentArray! {
            let text = item
            let newCell = SFCell(frame: CGRect(x: 0, y: 0, width: scrollView!.frame.width, height: scrollView!.frame.height))
            
            var origin : CGPoint?
            var size : CGSize?
            if cellSizeStyle == SFCellSizeStyle.fixed && orienation == SFOrienation.horizontal{
                ///Horizontal && Fixed Size
                if cells.count != 0{
                    origin = CGPoint(x: CGRectGetMaxX((cells.lastObject as! SFCell).frame), y: 0)
                }else{
                    origin = CGPoint(x: 0, y: 0)
                }

                size = fixedCellSize
                
                
                
            }else if cellSizeStyle == SFCellSizeStyle.fixed && orienation == SFOrienation.vertical{
                ///Vertical && Fixed Size
                if cells.count != 0{
                    origin = CGPoint(x: 0, y: CGRectGetMaxY((cells.lastObject as! SFCell).frame))
                }else{
                    origin = CGPoint(x: 0, y: 0)
                }
                fixedCellSize = CGSize(width: frame.width, height: 280)
                size = fixedCellSize
                
            }else if cellSizeStyle == SFCellSizeStyle.custom && orienation == SFOrienation.horizontal{
                ///Horizontal && Change next lines to desired size
                newCell.setUpSize(true)
                if cells.count != 0{
                    origin = CGPoint(x: CGRectGetMaxX((cells.lastObject as! SFCell).frame), y: 0)
                }else{
                    origin = CGPoint(x: 0, y: 0)
                }
                
                size = newCell.bounds.size
                
            }else if cellSizeStyle == SFCellSizeStyle.custom && orienation == SFOrienation.vertical{
                ///Vertical && Change next lines to desired size
                newCell.setUpSize(false)
                if cells.count != 0{
                    origin = CGPoint(x: 0, y: CGRectGetMaxY((cells.lastObject as! SFCell).frame))
                }else{
                    origin = CGPoint(x: 0, y: 0)
                }
                
                size = newCell.bounds.size
                
            }
            newCell.frame = CGRect(origin: origin!, size: size!)
            
            cells.addObject(newCell)
            newCell.setImageWithURL(text)
            
            scrollView!.addSubview(newCell)
            
            
        }
        var y : CGFloat = 0.0
        var x : CGFloat = 0.0

        for viewA in scrollView!.subviews{
            if viewA.isKindOfClass(SFCell){
                if y < CGRectGetMaxY(viewA.frame){
                    y += viewA.frame.height
                }
                if x < CGRectGetMaxX(viewA.frame){
                    x += viewA.frame.width
                }
                
            }
        }
        scrollView!.contentSize = CGSize(width: x, height: y)
        scrollView?.setContentOffset(CGPoint(x: scrollView!.contentOffset.x, y: scrollView!.contentSize.height - fixedCellSize!.height), animated: false)
        repositionEachCell(scrollView!)
        containsSomething = true
    }
    func releaseEverything(){
        containsSomething = false
        for var cell : SFCell in cells.mutableCopy() as! [SFCell]{
            cell.removeFromSuperview()
        }
        cells.removeAllObjects()
        
    }

    override func layoutSubviews() {
        //if bounds changes, reposiotion each cell
        repositionEachCell(scrollView!)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //reposiotion each cell while scrolling
        repositionEachCell(scrollView)
    }
    
    func repositionEachCell(scrollView : UIScrollView){
        for var cell : SFCell in cells.mutableCopy() as! [SFCell]{
            
            //next the magic happens, well, not really magic, but this is main thing!
            
            
            let point = scrollView.convertPoint(cell.center, toView: self)
            let offset = CGFloat(cells.indexOfObject(cell)) * offsetGap!
            let reversedOffset = CGFloat((cells.count - 1) - cells.indexOfObject(cell)) * offsetGap!
            if (orienation == SFOrienation.horizontal ? point.x : point.y) < (orienation == SFOrienation.horizontal ? (cell.frame.width * 0.5) + offset : (cell.frame.height * 0.5) + offset){
                // if cell is touched to the left side or top (depends on orientaion)
                let translationX = ((cell.frame.width * 0.5) - point.x) + offset
                let translationY = ((cell.frame.height * 0.5) - point.y) + offset
               print(scrollView.contentOffset.y)
                (orienation == SFOrienation.horizontal) ? (cell.transform = CGAffineTransformMakeTranslation(translationX, 0)) : (cell.transform = CGAffineTransformMakeTranslation(0, translationY))
                
                
                scrollView.bringSubviewToFront(cell)
                
        
                
                
            }/*else if (orienation == SFOrienation.horizontal ? point.x : point.y) > (orienation == SFOrienation.horizontal ? scrollView.frame.width - ((cell.frame.width * 0.5) + reversedOffset) : scrollView.frame.height - ((cell.frame.height * 0.5) + reversedOffset)){
                /*// if cell is touched to the rigth side or buttom (depends on orientaion)
                
                let translationX = (point.x - (scrollView.frame.width - (cell.frame.width * 0.5)) + reversedOffset)
                let translationY = (point.y - (scrollView.frame.height - (cell.frame.height * 0.5)) + reversedOffset)
                
                (orienation == SFOrienation.horizontal) ? (cell.transform = CGAffineTransformMakeTranslation(-translationX, 0)) : (cell.transform = CGAffineTransformMakeTranslation(0, -translationY))
                */
                //
            */else{
                //if cell is in the middle
                cell.transform = CGAffineTransformIdentity
                scrollView.bringSubviewToFront(cell)
                }
            }
            
            
        }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



public let sfMaskBoth : UIViewAutoresizing = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]


class SFCell: UIView {
    
    var line = 0
    var row = 0
    ///Put your stuff in contentView
    var contentView : UIView?
    var imageView : UIImageView?
    var closeButton : UIButton?
    var resizableView : UIView?
    var hugeImage : UIImageView?
    var origin : CGPoint?
    var oldPoint : CGPoint?
    var hugeImg : UIImage?
    var oldimage : UIImage?
    var blurRadius : Float = 0.0
    var backgroundImage : UIImageView?
    var topOnBack : UIView?
    var up : Bool = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        contentView?.autoresizingMask = sfMaskBoth
        addSubview(contentView!)
        imageView = UIImageView(frame: contentView!.bounds)
        imageView?.clipsToBounds = true
        imageView?.autoresizingMask = sfMaskBoth
        contentView!.addSubview(imageView!)
        contentView?.backgroundColor = cellColor
        contentView?.layer.borderColor = cellBorderColor.CGColor
        contentView?.layer.borderWidth = 1
        contentView?.layer.masksToBounds = true
        contentView?.layer.cornerRadius = 10
        imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        
        let tap = UITapGestureRecognizer(target: self, action: "resizeBigger")
        addGestureRecognizer(tap)
    }
    func resizeBigger(){
        
        if let c = homeController?.view{
        let rect = convertRect(contentView!.frame, toView: c)
        print(rect)
        resizableView = UIView(frame: rect)
        backgroundImage = UIImageView(frame: CGRect(x: -5, y: -5, width: resizableView!.bounds.width + 10, height: resizableView!.bounds.height + 10))
        backgroundImage?.autoresizingMask = sfMaskBoth
        topOnBack = UIView(frame: backgroundImage!.bounds)
        topOnBack?.backgroundColor = UIColor(rgba: "#2d353b")
        topOnBack?.alpha = 0.0
        topOnBack?.autoresizingMask = sfMaskBoth
        backgroundImage?.addSubview(topOnBack!)
        resizableView?.addSubview(backgroundImage!)
        closeButton = UIButton(type: UIButtonType.Custom)
        closeButton?.setImage(UIImage(named: "closeImage"), forState: UIControlState.Normal)
        closeButton?.frame = CGRect(x: resizableView!.frame.width - 70, y: 0, width: 70, height: 70)
        closeButton?.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
        hugeImage = UIImageView(frame: resizableView!.bounds)
        hugeImage!.contentMode = UIViewContentMode.ScaleAspectFit
        hugeImage?.alpha = 0.0
            oldimage = imageView?.image
        hugeImage!.image = imageView?.image
        hugeImage!.autoresizingMask = sfMaskBoth
        resizableView?.autoresizingMask = sfMaskBoth
        resizableView?.addSubview(hugeImage!)
    
        resizableView?.addSubview(closeButton!)
        c.addSubview(resizableView!)
        closeButton?.addTarget(self, action: "close", forControlEvents: UIControlEvents.TouchUpInside)
        
    UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.resizableView?.frame = c.bounds
            self.topOnBack?.alpha = 1.0
            self.hugeImage?.alpha = 1.0
            }) { (end) -> Void in
                let pan = UIPanGestureRecognizer(target: self, action: "pan:")
                self.resizableView?.addGestureRecognizer(pan)
        }
        
            print(c.frame)}
    }
    func pan(sender: UIPanGestureRecognizer){
        
        switch sender.state{
        case UIGestureRecognizerState.Began:
            oldPoint = sender.view!.frame.origin
            origin = sender.locationInView(sender.view!.superview)
            closeButton?.hidden = true
            
            break
        case UIGestureRecognizerState.Changed:
            let newPoint = sender.locationInView(sender.view!.superview)
            if newPoint.y < origin!.y {
                up = true
            }else if newPoint.y > origin!.y{
                up = false
            }
            let trans = sender.translationInView(sender.view!.superview)
            
            
            hugeImage!.frame.origin = CGPoint(x: resizableView!.frame.origin.x, y: oldPoint!.y + trans.y )
            let velo = sender.velocityInView(sender.view!.superview)
            let blur = Float(abs(hugeImage!.frame.origin.y) / sender.view!.frame.height)
            //print(blur)
            topOnBack?.alpha = CGFloat(1 - abs(blur))

           
           // print(velo.y)
            if abs(velo.y) > 1000{
                sender.enabled = false
            }
            
            
           
            
        
            break
        case UIGestureRecognizerState.Ended:
                //blurRadius = 1.0
                closeButton?.hidden = false
                if hugeImage!.frame.origin.y <= -(hugeImage!.frame.height * 0.5) || hugeImage!.frame.origin.y >= (hugeImage!.frame.height * 0.5){
                    fadeAway()
                    closeButton?.hidden = true
                }else{
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.hugeImage!.frame.origin = self.oldPoint!
                    })
                    
                }
            break
        case UIGestureRecognizerState.Cancelled:
            fadeAway()
                      break
        default:
            break
        }
    }
    func fadeAway(){
        closeButton?.hidden = true
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            
            self.topOnBack?.alpha = 0.0
            if self.up {
                self.hugeImage?.transform = CGAffineTransformMakeTranslation(0, -1400)
            }else{
                self.hugeImage?.transform = CGAffineTransformMakeTranslation(0, 1400)
            }
            }, completion: { (g) -> Void in
             self.resizableView?.removeFromSuperview()
             self.resizableView = nil
        })

    }
    func close(){
       fadeAway()
       
    }
    func setImageWithURL(imgAddress: String) {
        //print(imgAddress)
        
        imageView!.setImageWithUrl(NSURL(string: imgAddress)!, placeHolderImage: placeholderFull)
    }
    
    func setUpSize(horizotal : Bool){
        //Autogenerates random size
        ///Change size to the one you need
        
        self.bounds = CGRect(x: 0, y: 0, width: horizotal ? CGFloat(randomInRange(50, upper: 200)) : frame.width, height: horizotal ? frame.height : CGFloat(randomInRange(50, upper: 200)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}