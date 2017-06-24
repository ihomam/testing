//
//  infiniteCollectionView.swift
//  timeline
//
//  Created by Homam ll on 6/23/17.
//  Copyright © 2017 Homam. All rights reserved.
//

import UIKit


enum infiniteScrollDirection {
    case none
    case toTheFuture
    case toThePast
}

class infiniteCollectionView: UICollectionView, UICollectionViewDelegate {

    var scrolling:Bool = false
    var previousOffset:CGPoint = .zero
    var layoutEngine: infiniteLayoutEngine
    var scrollDirection:infiniteScrollDirection = .none
    var pages = [-1,0,1]
    var infiniteDelegate: infiniteCollectionViewDelegate?
    
    // MARK: ------------------
    // MARK: LifeCycle
    required init(withLayoutEngine layoutEngine:infiniteLayoutEngine) {
        self.layoutEngine = layoutEngine
        super.init(frame: .zero, collectionViewLayout: layoutEngine)
        self.isPagingEnabled = true;
        self.backgroundColor = UIColor.red
        self.delegate = self;
        self.isDirectionalLockEnabled = true;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented use init(withLayoutEngine:) instead")
    }
    // MARK: ------------------
    // MARK: DELEGATE
    // MARK:: UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrolling = true
    }
    func  scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.scrolling = true
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.scrolling = decelerate
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrolling = false
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scrolling = false
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrolling = true
        if self.layoutEngine.scrollLayout == .horizontal {
            self.scrollViewDidScrollHorizontally(scrollView,
                                                 loadedPages: self.layoutEngine.numLoadedPages,
                                                 displayedPages: self.layoutEngine.numDisplayedPages)
        }else{
            self.scrollViewDidScrollVertically(scrollView,
                                               loadedPages: self.layoutEngine.numLoadedPages,
                                               displayedPages: self.layoutEngine.numDisplayedPages)
        }
    }
    
    func scrollViewDidScrollHorizontally(_ scrollView: UIScrollView, loadedPages:UInt, displayedPages: UInt) {
        let currentOffsetX = scrollView.contentOffset.x;
        let currentPageSize = scrollView.frame.size.width;
        let currentScrollSize = scrollView.frame.size.width * CGFloat(displayedPages);
        let scrollDirection = self.previousOffset.x - currentOffsetX;

        // going backward
        if (scrollDirection > 0) {
            self.scrollDirection = .toThePast;
        }
        // going forward
        else if (scrollDirection < 0){
            self.scrollDirection = .toTheFuture;
        }
        
        if (self.scrollDirection == .toThePast && currentOffsetX < currentPageSize){
            let x = currentOffsetX+currentPageSize*CGFloat((loadedPages-displayedPages));
            let y = scrollView.contentOffset.y;
            self.previousOffset.x = 0;
            self.moveDatasource(.toThePast)
            scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        }
        else if (self.scrollDirection == .toTheFuture && currentOffsetX > currentScrollSize){
            let x = currentOffsetX-currentPageSize*CGFloat((loadedPages-displayedPages));
            let y = scrollView.contentOffset.y;
            self.previousOffset.x = 0;
            self.moveDatasource(.toTheFuture)
            scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        }
        else{
            self.previousOffset.x = currentOffsetX;
        }
    }
    func scrollViewDidScrollVertically(_ scrollView: UIScrollView, loadedPages:UInt, displayedPages: UInt) {
        let currentOffsetY = scrollView.contentOffset.y;
        let currentPageSize = scrollView.frame.size.height;
        let currentScrollSize = scrollView.frame.size.height * CGFloat(displayedPages);
        let scrollDirection = self.previousOffset.y - currentOffsetY;
        
        // going backward
        if (scrollDirection > 0) {
            self.scrollDirection = .toThePast;
        }
        // going forward
        else if (scrollDirection < 0){
            self.scrollDirection = .toTheFuture;
        }
        
        
        if (self.scrollDirection == .toThePast && currentOffsetY < currentPageSize){
            let x = scrollView.contentOffset.x;
            let y = currentOffsetY+currentPageSize*CGFloat((loadedPages-displayedPages));
            self.previousOffset.y = 0;
            self.moveDatasource(.toThePast)
            scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        }
        else if (self.scrollDirection == .toTheFuture && currentOffsetY > currentScrollSize){
            let x = scrollView.contentOffset.x;
            let y = currentOffsetY-currentPageSize*CGFloat((loadedPages-displayedPages));
            self.previousOffset.y = 0;
            self.moveDatasource(.toTheFuture)
            scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        }
        else{
            self.previousOffset.y = currentOffsetY;
        }
    }
    
    // MARK: ------------------
    // MARK: DATASOURCE 
    func moveDatasource(_ scrollDirection:infiniteScrollDirection){
        guard scrollDirection != .none, pages.count == Int(self.layoutEngine.numDisplayedPages) else {
            fatalError("somthing is wrong \(pages) \(scrollDirection)")
        }
        
        if scrollDirection == .toTheFuture {
            var pagesSubset = self.pages.suffix(2)
            let newPage = pagesSubset.last!+1
            pagesSubset.append(pagesSubset.last!+1)
            self.pages = Array(pagesSubset)
            self.infiniteDelegate?.loadPage(newPage, pages: self.pages)
        }
        else{
            let newPage = self.pages.first!-1
            var pagesSubset = [newPage]
            pagesSubset.append(contentsOf: Array(self.pages.prefix(2)))
            self.pages = pagesSubset
            self.infiniteDelegate?.loadPage(newPage, pages: self.pages)
        }
        
        print(pages)
    }
}

protocol infiniteCollectionViewDelegate {
    func loadPage(_ page:Int, pages:[Int])
}
