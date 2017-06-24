//
//  timelineView.swift
//  timeline
//
//  Created by Homam ll on 6/23/17.
//  Copyright © 2017 Homam. All rights reserved.
//

import UIKit
import EventKit

class timelineView: UIView, infiniteViewDataSource, infiniteViewDelegate {
    let datasource:timelineViewDatasource
    var layoutEngine = timelineLayoutEngine()
    var mainView: infiniteView
    
    // MARK: ------------------
    // MARK: lifecycle
    public init(datasource:timelineViewDatasource){
        self.datasource = datasource
        self.mainView = infiniteView(withLayoutEngine: layoutEngine, customization: { (collection) in
            collection.register(timelineEventCell.self, forCellWithReuseIdentifier: timelineEventCell.identifier)
        })
        
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
        self.mainView.delegate = self
        self.mainView.dataSoruce = self
        self.addSubview(self.mainView)
    }
    
    // MARK:: layouting
    override func layoutSubviews() {
        super.layoutSubviews()
        self.mainView.frame = self.bounds
    }
    
    // MARK: DATASOURCE
    func prepareData() {
        
    }
    func loadPages(_ newPages: [Int], allPages: [Int]) {
        
    }
        
    // MARK:: UICollectionViewDataSource
    func infinteViewNumberOfEvents(_ infinteView: infiniteView, inPage: Int, section: Int) -> Int {
        return 1
    }
    func infinteViewLoadPages(_ infinteView: infiniteView, allPages: [Int]) {
        
    }
}

protocol timelineViewDatasource {
    func eventsBetween(startDate:Date, endDate:Date) -> [EKEvent]?
}
