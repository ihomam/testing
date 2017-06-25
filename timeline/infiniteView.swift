//
//  infiniteView.swift
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

class infiniteView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {

    var scrolling:Bool = false
    var previousOffset:CGPoint = .zero
    var layoutEngine: infiniteLayoutEngine
    var scrollDirection:infiniteScrollDirection = .none
    var loadedPages:[Int] = []
    var loadedSections:[Int] = []
    var delegate: infiniteViewDelegate?
    var dataSoruce: infiniteViewDataSource?
    var collectionView:UICollectionView
    
    // MARK: ------------------
    // MARK: LifeCycle
    required init(withLayoutEngine layoutEngine:infiniteLayoutEngine, customization: (UICollectionView) -> ()){
        self.layoutEngine = layoutEngine
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layoutEngine)
        customization(self.collectionView)
        super.init(frame: .zero)
        self.initialiseDataSource()
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented use init(withLayoutEngine:) instead")
    }
   
    // MARK: ------------------
    override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.frame = self.bounds
    }
    
    // MARK: ------------------
    // MARK: UI
    func setupViews() {
        self.collectionView.isPagingEnabled = true
        self.collectionView.backgroundColor = UIColor.red
        self.collectionView.isDirectionalLockEnabled = true
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.addSubview(self.collectionView)
    }
    // MARK: ------------------
    // MARK: SCROLLING 
    func scrollToInitialPage(){
//        let pageNumber = Int(ceil(Double(self.layoutEngine.numDisplayedPages) * 0.5));
//        self.scrollToPage(pageNumber, animated: false)
    }
    func scrollToPage(_ page:Int, animated:Bool) {
        if self.layoutEngine.scrollLayout == .horizontal {
            self.collectionView.setContentOffset(CGPoint(x: self.frame.size.width*CGFloat(page),
                                                         y: self.collectionView.contentOffset.y),
                                                 animated: animated)
        }else{
            fatalError("no vertical yet")
        }
    }
    // MARK: ------------------
    // MARK: DELEGATE
    // MARK:: UICollectionViewDelegate 
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            self.scrollToInitialPage()
        }
    }
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
            self.scrollDatasource(.toThePast)
            scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        }
        else if (self.scrollDirection == .toTheFuture && currentOffsetX > currentScrollSize){
            let x = currentOffsetX-currentPageSize*CGFloat((loadedPages-displayedPages));
            let y = scrollView.contentOffset.y;
            self.previousOffset.x = 0;
            self.scrollDatasource(.toTheFuture)
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
            self.scrollDatasource(.toThePast)
            scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        }
        else if (self.scrollDirection == .toTheFuture && currentOffsetY > currentScrollSize){
            let x = scrollView.contentOffset.x;
            let y = currentOffsetY-currentPageSize*CGFloat((loadedPages-displayedPages));
            self.previousOffset.y = 0;
            self.scrollDatasource(.toTheFuture)
            scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        }
        else{
            self.previousOffset.y = currentOffsetY;
        }
    }
    
    // MARK: ------------------
    // MARK: DATASOURCE
    
    /// starts from 0 and ends at 4 == self.layoutEngine.numLoadedPages - 1
    var currentPageNumber:UInt {
        get {
            var page:UInt = 0
            let layoutType = self.layoutEngine.scrollLayout
            let pageSize = self.layoutEngine.pageSize
            if layoutType == .horizontal {
                page = UInt(ceil(self.collectionView.contentOffset.x / pageSize.width))
            }else if layoutType == .vertical{
                fatalError()
            }
            
            return page
        }
    }

    func initialiseDataSource() {
        let pagesNum = Int(self.layoutEngine.numLoadedPages)
        let startPageIndex = Int(floor(Double(pagesNum) * 0.5) * -1)
        
        // startIndex got calculated for a reason because
        // loaded pages should always start with a negative value 
        // ex: 
        // 3 = [9223372036854775807,0,9223372036854775807]
        // 5 = [9223372036854775807,-1,0,1,9223372036854775807]
        for i in 0..<pagesNum {
            var value = Int.max
            if self.layoutEngine.isVisiblePage(UInt(i)){
                value = i+startPageIndex
            }
            self.loadedPages.append(value)
        }
        self.dataSoruce?.infinteViewLoadPages(self, allPages: self.loadedPages)
    }
    func scrollDatasource(_ scrollDirection:infiniteScrollDirection){
        guard scrollDirection != .none, loadedPages.count == Int(self.layoutEngine.numLoadedPages) else {
            fatalError("somthing is wrong \(loadedPages) \(scrollDirection)")
        }
        
        let loadedPagesCount = Int(self.layoutEngine.numLoadedPages)
        // example
        // loadedPages = [9223372036854775807,-1,0,1,9223372036854775807]
        
        if scrollDirection == .toTheFuture {
            var newPages:[Int] = []
            var startValue =  self.loadedPages[Int(self.layoutEngine.pagesUpperBound)-1]
            
            for i in 0..<loadedPagesCount {
                var value = Int.max
                if self.layoutEngine.isVisiblePage(UInt(i)){
                    startValue += 1
                    value = startValue
                }
                newPages.append(value)
            }
            // becomes
            // loadedPages = [9223372036854775807,1,2,3,9223372036854775807]
            self.loadedPages = newPages
            self.dataSoruce?.infinteViewLoadPages(self, allPages: self.loadedPages)
        }
        else{
            let startValue =  self.loadedPages[Int(self.layoutEngine.pagesLowerBound)+1]
            
            var newPages:[Int] = []
            for i in (0..<loadedPagesCount).reversed() {
                var value = Int.max
                if self.layoutEngine.isVisiblePage(UInt(i)){
                    value = startValue - i + 1
                }
                newPages.append(value)
            }
            // becomes
            // loadedPages = [9223372036854775807,-3,-2,-1,9223372036854775807]
            self.loadedPages = newPages
            self.dataSoruce?.infinteViewLoadPages(self, allPages: self.loadedPages)
        }
        
        self.collectionView.reloadData()
    }
    
    // MARK:: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Int(self.layoutEngine.numLoadedPages * self.layoutEngine.numSectionsInPage)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(section)
        let sectionNumber = CGFloat(section)
        let sectionsInPage = CGFloat(self.layoutEngine.numSectionsInPage)
        let sectionOrderInPage = (section < Int(sectionsInPage)) ? section : section % Int(sectionsInPage)
        let pageNumber = floor(sectionNumber/sectionsInPage)
        guard self.layoutEngine.isVisiblePage(UInt(pageNumber)) else {
            return 0
        }
        
        return self.dataSoruce!.infinteViewNumberOfEvents(self,
                                                          inPage: self.loadedPages[Int(pageNumber)],
                                                          section: sectionOrderInPage)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: timelineEventCell.identifier, for: indexPath) as! timelineEventCell

        cell.laTitle.text = String(self.loadedPages[indexPath.section])
        
        return cell
    }
}
protocol infiniteViewDataSource {
    func infinteViewLoadPages (_ infinteView:infiniteView, allPages:[Int])
    func infinteViewNumberOfEvents(_ infinteView:infiniteView, inPage:Int, section:Int) -> Int
}

protocol infiniteViewDelegate {

}
