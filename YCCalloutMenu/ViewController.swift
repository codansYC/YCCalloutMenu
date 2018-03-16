//
//  ViewController.swift
//  YCCalloutMenu
//
//  Created by yuanchao on 2018/3/3.
//  Copyright © 2018年 yuanchao. All rights reserved.
//

import UIKit

class ViewController: UIViewController, YCCalloutMenuViewDelegate {

    var menu: YCCalloutMenuView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
        let btn = UIButton.init(type: .system)
        btn.frame = CGRect.init(x: 240, y: 100, width: 80, height: 34)
        btn.setTitle("点我", for: .normal)
        btn.addTarget(self, action: #selector(click), for: .touchUpInside)
        view.addSubview(btn)
        btn.backgroundColor = UIColor.green
        
        let item = UIBarButtonItem.init(title: "更多", style: .plain, target: self, action: #selector(click))
        navigationItem.rightBarButtonItem = item
        
        menu = YCCalloutMenuView.init(invoker: self, control: btn, delegate: nil, txts: ["添加好友","消息","分享"], icons: [UIImage.init(named: "add_2")!, UIImage.init(named: "announcements")!, UIImage.init(named: "green_share")!], direction: .up)
        menu.menuBgColor = UIColor.black.withAlphaComponent(0.7)
        menu.rowHighlightColor = UIColor.black
        menu.textColor = UIColor.init(red: 52.0/255, green: 200.0/255, blue: 108.0/255, alpha: 1)
        menu.textFont = UIFont.systemFont(ofSize: 13)
        menu.arrowAngle = CGFloat.pi / 2.5
        menu.arrowHeight = 5
        menu.paddingIconToText = 6
        menu.distanceToControl = 3
        menu.lineColor = UIColor.white.withAlphaComponent(0.3)
        menu.lineHeight = 0.5
        
    }

    @objc func click() {
        menu.show()
    }
    
    func calloutMenuView(calloutMenuView: YCCalloutMenuView, selectedIndex index: Int) {
        print(index)
    }
}

