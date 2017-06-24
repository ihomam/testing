//
//  timelineView.swift
//  timeline
//
//  Created by Homam ll on 6/23/17.
//  Copyright © 2017 Homam. All rights reserved.
//

import UIKit
import EventKit

class timelineView: UIView, UICollectionViewDataSource, infiniteCollectionViewDelegate {
    let datasource:timelineViewDatasource
    var layoutEngine = timelineLayoutEngine()
    let collectionView: infiniteCollectionView
    
    // MARK: ------------------
    // MARK: lifecycle
    public init(datasource:timelineViewDatasource){
        self.datasource = datasource
        self.collectionView = infiniteCollectionView(withLayoutEngine: self.layoutEngine)
        super.init(frame:.zero)
        
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not implemented, call init(datasource:) instead")
    }
    
    required override init(frame: CGRect) {
        fatalError("init(frame:) is not implemented, call init(datasource:) instead")
    }
    // MARK: ------------------
    // MARK: VIEWS
    func setupViews() {
        self.collectionView.infiniteDelegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(timelineEventCell.self, forCellWithReuseIdentifier: timelineEventCell.identifier)
        self.addSubview(self.collectionView)
    }
    
    // MARK:: layouting
    override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.frame = self.bounds
    }
    
    // MARK: DATASOURCE
    func prepareData() {
        
    }
    
    // MARK:: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Int(self.layoutEngine.numLoadedPages * self.layoutEngine.numSectionsInPage)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: timelineEventCell.identifier, for: indexPath) as! timelineEventCell
        
        cell.laTitle.text = String(indexPath.row)
        
        
        return cell
    }
}

protocol timelineViewDatasource {
    func eventsBetween(startDate:Date, endDate:Date) -> [EKEvent]?
}
