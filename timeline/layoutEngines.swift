//
//  layoutEngines.swift
//  timeline
//
//  Created by Homam ll on 6/24/17.
//  Copyright © 2017 Homam. All rights reserved.
//

import Foundation
import UIKit

enum infiniteScrollLayout {
    case horizontal
    case vertical
}

class infiniteLayoutEngine : UICollectionViewLayout {
    var scrollLayout:infiniteScrollLayout = .horizontal
    var numLoadedPages:UInt = 5
    var numDisplayedPages:UInt = 3
}

class timelineLayoutEngine : infiniteLayoutEngine {
    var validLayout = false
    var pageHeight:CGFloat = 0.0
    var layoutInfo:[Int:[IndexPath:UICollectionViewLayoutAttributes]] = [:]
    var numSectionsInPage: UInt = 1
    
    // MARK: ------------------
    //MARK: Lifecycle
    override init() {
        super.init()
        self.scrollLayout = .horizontal
        self.numLoadedPages = 5
        self.numDisplayedPages = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented use init() instead")
    }
    
    // MARK: ------------------
    //MARK: UICollectionViewLayout
    override var collectionViewContentSize:CGSize {
        get{
            return CGSize(width: self.pageSize.width*CGFloat(self.numLoadedPages), height: self.pageSize.height)
        }
    }
    
    override func prepare() {
        guard validLayout == false, let collectionView = collectionView else {
            return
        }
        
        var layoutObjects:[Int:[IndexPath:UICollectionViewLayoutAttributes]] = [:]
        
        let sectionWidth = self.pageSize.width / CGFloat(self.numSectionsInPage);
        let sectionHeight = self.pageSize.height;
        let sectionCount = collectionView.numberOfSections
        
        for section in 0..<sectionCount {
            let itemsCount = collectionView.numberOfItems(inSection: section)
            let itemHeight = sectionHeight/CGFloat(itemsCount);
            let itemX = sectionWidth * CGFloat(section);
            var layoutObjectsInSection: [IndexPath:UICollectionViewLayoutAttributes] = [:]
            
            
            for item in 0..<itemsCount {
                let idxPath = IndexPath(item: item, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: idxPath)
                attributes.frame = CGRect(x: itemX, y: itemHeight*CGFloat(item), width: sectionWidth, height: itemHeight)
                layoutObjectsInSection[idxPath] = attributes;
            }
            
            layoutObjects[section] = layoutObjectsInSection;
        }
        
        self.layoutInfo = layoutObjects;
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes:[UICollectionViewLayoutAttributes] = []
        
        for (_, element) in self.layoutInfo.enumerated() {
            for (_,element) in element.value.enumerated() {
                if rect.intersects(element.value.frame) {
                    attributes.append(element.value)
                }
            }
        }
        
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {

        guard self.layoutInfo.count < indexPath.section else {
            return nil
        }
        
        return self.layoutInfo[indexPath.section]?[indexPath]
    }

    override func invalidateLayout() {
        self.validLayout = false
        super.invalidateLayout()
    }
    
    
    // MARK: ------------------
    var pageSize :CGSize {
        get{
            guard let collectionView = collectionView else {
                return .zero
            }
            
            if (self.pageHeight == 0) {
                self.pageHeight = collectionView.frame.size.height*2;
            }
            return CGSize(width: collectionView.frame.size.width, height: self.pageHeight)
        }
    }
}
