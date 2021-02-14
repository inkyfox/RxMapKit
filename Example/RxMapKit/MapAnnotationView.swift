//
//  MapAnnotationView.swift
//  RxMapKit_Example
//
//  Created by YYKJ0048 on 2021/2/12.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import MapKit

class MapAnnotationView: MKAnnotationView {
        
    static func instance() -> MapAnnotationView {
        let view = MapAnnotationView()
        return view
    }
    
    lazy var countLabel: UILabel = {
        let label = UILabel()
        label.text = "12"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(countLabel)
        countLabel.snp.remakeConstraints { make in
            make.center.equalToSuperview()
//            make.left.equalTo(10)
        }
    }
}
