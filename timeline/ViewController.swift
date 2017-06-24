//
//  ViewController.swift
//  timeline
//
//  Created by Homam ll on 6/23/17.
//  Copyright © 2017 Homam. All rights reserved.
//

import UIKit
import EventKit

class ViewController: UIViewController, timelineViewDatasource {

    lazy var timeline: timelineView = {
        return timelineView(datasource: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.timeline)
    }
    
    override func viewDidLayoutSubviews() {
        timeline.frame = self.view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func eventsBetween(startDate:Date, endDate:Date) -> [EKEvent]? {
        return nil
    }
}

