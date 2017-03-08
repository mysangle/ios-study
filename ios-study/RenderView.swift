//
//  RenderView.swift
//  ios-study
//
//  Created by soonhyung-imac on 3/7/17.
//  Copyright © 2017 twentyhours. All rights reserved.
//

import UIKit

public class RenderView: UIView {
    // deserialize
    required public init?(coder:NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    func commonInit() {
        self.contentScaleFactor = UIScreen.main.scale
        
        let eaglLayer = self.layer as! CAEAGLLayer
        eaglLayer.isOpaque = true
        eaglLayer.drawableProperties = [NSNumber(value: false): kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8: kEAGLDrawablePropertyColorFormat]
    }
}
