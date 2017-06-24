//
//  timelineViewEventUI.swift
//  timeline
//
//  Created by Homam ll on 6/24/17.
//  Copyright © 2017 Homam. All rights reserved.
//

import Foundation
import UIKit

class timelineEventCell: UICollectionViewCell {
    static let identifier = "timelineEventCellIdentifier"
    
    
    //MARK: LifeCycle 
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    //MARK: UICollectionViewCell
    override func prepareForReuse() {
        self.laTitle.text = nil
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.laTitle.frame = self.contentView.bounds
    }
    
    //MARK: UI properties
    lazy var laTitle:UILabel = {
        var label = UILabel(frame: .zero)
        label.textAlignment = .center
        
        return label
    }()
    
    func setupViews() {
        self.contentView.addSubview(self.laTitle)
        self.contentView.backgroundColor = UIColor.white
    }
    
}
