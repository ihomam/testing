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
    var calendar = Calendar.current
    let today = Calendar.current.startOfDay(for: Date())
    var eventsDays:[Date:[EKEvent]] = [:]
    let objects = objectsStore()
    
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
    // MARK:: infiniteViewDataSource
    func infinteViewNumberOfEvents(_ infinteView: infiniteView, inPage: Int, section: Int) -> Int {
        let day = self.calendar.date(byAdding:.day, value: inPage, to: today)!
        if self.eventsDays[day] == nil {
            let df = DateFormatter()
            df.dateStyle = .full
            df.timeStyle = .full
            let endDay = self.calendar.date(bySettingHour: 23, minute: 59, second: 59, of: day)
            self.eventsDays[day] = self.objects.getEvents(startDate: day, endDate: endDay!)
            return self.eventsDays[day]?.count ?? 0
        }else{
            return self.eventsDays[day]?.count ?? 0
        }
    }
    func infinteViewLoadPages(_ infinteView: infiniteView, allPages: [Int]) {
        allPages.forEach { (todayOffset) in
            let day = self.calendar.date(byAdding:.day, value: todayOffset, to: today)!
            if self.eventsDays[day] == nil {
                let df = DateFormatter()
                df.dateStyle = .full
                df.timeStyle = .full
                let endDay = self.calendar.date(bySettingHour: 23, minute: 59, second: 59, of: day)
                self.eventsDays[day] = self.objects.getEvents(startDate: day, endDate: endDay!)
            }
        }
    }
}

protocol timelineViewDatasource {
    func eventsBetween(startDate:Date, endDate:Date) -> [EKEvent]?
}
