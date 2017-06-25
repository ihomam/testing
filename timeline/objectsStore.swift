//
//  objectsStore.swift
//  timeline
//
//  Created by Homam ll on 6/25/17.
//  Copyright © 2017 Homam. All rights reserved.
//

import UIKit
import EventKit
class objectsStore: NSObject {
    let eventStore:EKEventStore = EKEventStore()
    
    func getEvents(startDate:Date, endDate:Date) -> [EKEvent] {
        let calendars = self.eventStore.calendars(for: .event)
        let predicate = self.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        return self.eventStore.events(matching: predicate)
    }
}
