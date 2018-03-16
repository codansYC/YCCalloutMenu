//
//  YCCalloutMenuView.swift
//  YCCalloutMenu
//
//  Created by yuanchao on 2018/3/3.
//  Copyright © 2018年 yuanchao. All rights reserved.
//

import UIKit

fileprivate let WIDTH = UIScreen.main.bounds.width
fileprivate let HEIGHT = UIScreen.main.bounds.height

/*
 ＊协议
 */
protocol YCCalloutMenuViewDelegate: class {
    
    func calloutMenuView(calloutMenuView:YCCalloutMenuView, selectedIndex index:Int)
}

class YCCalloutMenuView: UIView, UITableViewDelegate, UITableViewDataSource, CAAnimationDelegate {
    
    /*
     *指定箭头的原点
     */
    var designatedArrowPoint: CGPoint?
  
    /*
     *触发控件
     */
    weak var control: UIControl?
    
    /*
     *控制器
     */
    weak var invoker: UIViewController?
    
    /*
     *文字选项
     */
    var textOptions: [String]! {
        didSet{
            setConfigure()
        }
    }
    
    /*
     *图片选项
     */
    var iconOptions: [UIImage]? {
        didSet{
            setConfigure()
        }
    }
    
    /*
     *箭头方向
     */
    var arrowDirection = ArrowDirection.up {
        didSet{
            setConfigure()
        }
    }
    
    /*
     *动画时长
     */
    var animationDuration = 0.15
    
    /*
     *菜单背景色
     */
    var menuBgColor: UIColor = UIColor.white 
    
    /*
     *文字颜色
     */
    var textColor: UIColor = UIColor.black
    
    /*
     *距离触发控件的距离
     */
    var distanceToControl: CGFloat = 8

    
    /*
     *距离控制器的最小外边距
     */
    var minMarginToInvoker: UIEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16)
    
    /*
     *箭头高度
     */
    var arrowHeight: CGFloat = 8.0
    
    /*
     *箭头顶角角度
     */
    var arrowAngle = CGFloat.pi / 2
    
    /*
     *行高
     */
    var rowHeight: CGFloat = 30 {
        didSet{
            setConfigure()
        }
    }
    
    /*
     *选中时的颜色
     */
    var rowHighlightColor: UIColor = UIColor.green
    
    /*
     *左边距
     */
    var paddingLeft: CGFloat = 10 {
        didSet{
            setConfigure()
        }
    }
    
    /**右边距*/
    var paddingRight: CGFloat = 10 {
        didSet{
            setConfigure()
        }
    }
    
    /**图片与文字间的间距*/
    var paddingIconToText: CGFloat = 5 {
        didSet{
            setConfigure()
        }
    }
    
    /*
     *分割线距离左边的宽度
     */
    var lineEdgeLeft: CGFloat = 10
    
    /*
     *分割线距离右边的宽度
     */
    var lineEdgeRight: CGFloat = 10
    
    /*
     *分割线高度
     */
    var lineHeight: CGFloat = 0.5
    
    /*
     *分割线颜色
     */
    var lineColor: UIColor = UIColor.gray
    
    /*
     *字体大小
     */
    var textFont: UIFont = WIDTH >= 414 ? UIFont.systemFont(ofSize: 15) : WIDTH >= 375 ? UIFont.systemFont(ofSize: 14) : UIFont.systemFont(ofSize: 13) {
        didSet{
            setConfigure()
        }
    }
    /*
     *图片的最大宽度
     */
    private var iconMaxW: CGFloat {
        guard textOptions != nil,
            let icons = iconOptions,
            !textOptions.isEmpty,
            icons.count >= textOptions.count else {
            return 0
        }
        
        var w: CGFloat = 0
        for icon in icons {
            let p = icon.size.width / icon.size.height
            w = max(w, min(rowHeight, icon.size.height) * p)
        }
        return w
    }
    
    
    //文字最大宽度
    private var txtMaxW: CGFloat {
        guard textOptions != nil  else {
            return 0
        }
        var w: CGFloat = 0
        for txt in textOptions {
            w = max((txt as NSString).size(withAttributes: [NSAttributedStringKey.font: textFont]).width, w)
        }
        return w
    }
    
    //视图宽度
    var width: CGFloat {
        let w = paddingLeft + iconMaxW + paddingIconToText + txtMaxW + paddingRight
        switch arrowDirection {
        case .up, .down:
            return w
        default:
            return w + arrowHeight
        }
    }
    
    //视图高度
    var height: CGFloat {
        let h = CGFloat(textOptions.count) * rowHeight
        switch arrowDirection {
        case .up, .down:
            return h + arrowHeight
        default:
            return h
        }
    }
    
    private var coverView: UIView!  //底部蒙层
    
    //显示选项内容的表视图
    private var tableView: UITableView!
    
    /**代理*/
    weak var delegate: YCCalloutMenuViewDelegate?
    
    private let cellResueIdentfier = "cell"
    private let shrinkAnimationKey = "shrink"
    private let enlargeAnimationKey = "enlarge"
    
    //外界初始化方法
    init(invoker: UIViewController, control: UIControl, delegate: YCCalloutMenuViewDelegate? = nil, txts: [String],icons: [UIImage]? = nil, direction: ArrowDirection = .up) {
        super.init(frame: .zero)
        backgroundColor = UIColor.clear
        
        self.invoker = invoker
        self.control = control
        self.delegate = delegate
        self.textOptions = txts
        self.iconOptions = icons
        self.arrowDirection = direction
        
        initCoverView()
        
        initTableView()
        
        setConfigure()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 初始化蒙层
    private func initCoverView() {
        coverView = UIView(frame: UIScreen.main.bounds)
        coverView.backgroundColor = UIColor.black.withAlphaComponent(0)
        coverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    
    //初始化表视图
    private func initTableView() {
        let tableViewFrm = CGRect.init(x: 0, y: 0, width: width, height: height)
        tableView = UITableView.init(frame: tableViewFrm, style: .plain)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MenuCell.self, forCellReuseIdentifier: cellResueIdentfier)
        tableView.backgroundColor = menuBgColor
        tableView.isScrollEnabled = false
        addSubview(tableView)
        
    }
    
    //MARK: - 设置
    private func setConfigure() {
        frame.size = CGSize.init(width: width, height: height)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellResueIdentfier, for: indexPath) as! MenuCell
        cell.label.text = textOptions[indexPath.row]
        if let icons = iconOptions, icons.count > indexPath.row {
            cell.imageV.image = icons[indexPath.row]
        }
        cell.divLine.isHidden = indexPath.row == textOptions.count - 1
        configureCellStyle(cell: cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.calloutMenuView(calloutMenuView: self, selectedIndex: indexPath.row)
        (tableView.cellForRow(at: indexPath) as? MenuCell)?.contentView.backgroundColor = rowHighlightColor
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.15) {
            self.dismiss()
        }
    }
    
    private func configureCellStyle(cell: MenuCell) {
        cell.backgroundColor = menuBgColor
        cell.contentView.backgroundColor = menuBgColor
        cell.selectionStyle = .none
        
        let imageV = cell.imageV
        let label = cell.label
        if let img = imageV.image {
            imageV.frame = CGRect.init(x: paddingLeft, y: 0, width: iconMaxW, height: rowHeight)
            if iconMaxW >= img.size.width || iconMaxW >= img.size.height {
                imageV.contentMode = .center
            } else {
                imageV.contentMode = .scaleAspectFit
            }
            label.frame.origin.x = imageV.frame.origin.x+iconMaxW+paddingIconToText
            label.center.y = imageV.center.y
            label.textAlignment = .left
        } else {
            label.center = cell.contentView.center
            label.textAlignment = .center
        }
        label.frame.size = CGSize.init(width: txtMaxW, height: textFont.lineHeight)
        label.textColor = textColor
        label.font = textFont
        cell.divLine.frame = CGRect.init(x: lineEdgeLeft, y: cell.frame.height-lineHeight, width: cell.frame.width - lineEdgeLeft - lineEdgeRight, height: lineHeight)
        cell.divLine.backgroundColor = lineColor
        
    }
    
    // 三个顶角顺序为顺时针
    private var point1OfArrow = CGPoint.zero
    private var point2OfArrow = CGPoint.zero
    private var point3OfArrow = CGPoint.zero
    
    override func draw(_ rect: CGRect) {
        
        guard let invoker = invoker  else {
            return
        }
        
        if designatedArrowPoint == nil {
            guard let control = control else {
                return
            }
            let controlFrm = control.convert(control.bounds, to: invoker.view)
            switch arrowDirection {
            case .up:
                designatedArrowPoint = CGPoint.init(x: controlFrm.midX, y: controlFrm.origin.y + controlFrm.size.height + distanceToControl)
            case .down:
                designatedArrowPoint = CGPoint.init(x: controlFrm.midX, y: controlFrm.origin.y - distanceToControl)
            case .left:
                designatedArrowPoint = CGPoint.init(x: controlFrm.origin.x + controlFrm.width + distanceToControl, y: controlFrm.midY)
            case .right:
                designatedArrowPoint = CGPoint.init(x: controlFrm.origin.x - distanceToControl, y: controlFrm.midY)
            }
        }
        
        calculateAnglePoint()
        
        //绘三角形箭头
        let triPath = UIBezierPath()
        triPath.move(to: point1OfArrow)
        triPath.addLine(to: point2OfArrow)
        triPath.addLine(to: point3OfArrow)
        triPath.close()
        menuBgColor.setFill()
        triPath.fill()
        
    }
    
    private func calculateAnglePoint() {
        guard let invoker = invoker, let arrowPoint = designatedArrowPoint else {
            return
        }
        frame.size = CGSize.init(width: width, height: height)
        switch arrowDirection {
        case .up:
            frame.origin.x = min(max(arrowPoint.x - width / 2, minMarginToInvoker.left), invoker.view.bounds.width - minMarginToInvoker.right - width)
            frame.origin.y = arrowPoint.y
            
            point1OfArrow = invoker.view.convert(arrowPoint, to: self)
            point2OfArrow.x = point1OfArrow.x + arrowHeight * tan(arrowAngle / 2)
            point2OfArrow.y = arrowHeight
            point3OfArrow.x = point1OfArrow.x - arrowHeight * tan(arrowAngle / 2)
            point3OfArrow.y = arrowHeight
            
            let tableFrm = CGRect.init(x: 0, y: arrowHeight, width: width, height: height-arrowHeight)
            tableView.frame = tableFrm
            tableView.layer.anchorPoint = CGPoint.init(x: point1OfArrow.x / width, y: 0)
            tableView.frame = tableFrm
        case .down:
            frame.origin.x = min(max(arrowPoint.x - width / 2, minMarginToInvoker.left), invoker.view.bounds.width - minMarginToInvoker.right - width)
            frame.origin.y = arrowPoint.y - height
            
            point1OfArrow = invoker.view.convert(arrowPoint, to: self)
            point2OfArrow.x = point1OfArrow.x - arrowHeight * tan(arrowAngle / 2)
            point2OfArrow.y = point1OfArrow.y - arrowHeight
            point3OfArrow.x = point1OfArrow.x + arrowHeight * tan(arrowAngle / 2)
            point3OfArrow.y = point1OfArrow.y - arrowHeight
            
            let tableFrm = CGRect.init(x: 0, y: 0, width: width, height: height-arrowHeight)
            tableView.frame = tableFrm
            tableView.layer.anchorPoint = CGPoint.init(x: point1OfArrow.x / width, y: 1)
            tableView.frame = tableFrm
        case .left:
            frame.origin.x = arrowPoint.x
            frame.origin.y = min(max(arrowPoint.y - height / 2, minMarginToInvoker.top), invoker.view.bounds.height - minMarginToInvoker.bottom - height)
            
            point1OfArrow = invoker.view.convert(arrowPoint, to: self)
            point2OfArrow.x = point1OfArrow.x + arrowHeight
            point2OfArrow.y = point1OfArrow.y - arrowHeight * tan(arrowAngle / 2)
            point3OfArrow.x = point1OfArrow.x + arrowHeight
            point3OfArrow.y = point1OfArrow.y + arrowHeight * tan(arrowAngle / 2)
            
            let tableFrm = CGRect.init(x: arrowHeight, y: 0, width: width - arrowHeight, height: height)
            tableView.frame = tableFrm
            tableView.layer.anchorPoint = CGPoint.init(x: 0, y: point1OfArrow.y / tableFrm.height)
            tableView.frame = tableFrm
        case .right:
            frame.origin.x = arrowPoint.x - width
            frame.origin.y = min(max(arrowPoint.y - height / 2, minMarginToInvoker.top), invoker.view.bounds.height - minMarginToInvoker.bottom - height)
            point1OfArrow = invoker.view.convert(arrowPoint, to: self)
            point2OfArrow.x = point1OfArrow.x - arrowHeight
            point2OfArrow.y = point1OfArrow.y + arrowHeight * tan(arrowAngle / 2)
            point3OfArrow.x = point1OfArrow.x - arrowHeight
            point3OfArrow.y = point1OfArrow.y - arrowHeight * tan(arrowAngle / 2)
            
            let tableFrm = CGRect.init(x: 0, y: 0, width: width - arrowHeight, height: height)
            tableView.frame = tableFrm
            tableView.layer.anchorPoint = CGPoint.init(x: 1, y: point1OfArrow.y / tableFrm.height)
            tableView.frame = tableFrm
        }
    }
    
    func show() {
        
        invoker?.view.addSubview(coverView)
        invoker?.view.addSubview(self)
        let anim = CABasicAnimation(keyPath: "transform.scale")
        anim.fromValue = 0
        anim.toValue = 1
        anim.duration = animationDuration
        anim.isRemovedOnCompletion = false
        anim.fillMode = kCAFillModeForwards
        anim.delegate = self
        tableView.layer.add(anim, forKey: enlargeAnimationKey)
        
    }
    
    @objc func dismiss() {
        
        let anim = CABasicAnimation(keyPath: "transform.scale")
        anim.toValue = 0
        anim.duration = animationDuration
        anim.isRemovedOnCompletion = false
        anim.fillMode = kCAFillModeForwards
        anim.delegate = self
        tableView.layer.add(anim, forKey: shrinkAnimationKey)
        
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim == tableView.layer.animation(forKey: enlargeAnimationKey) {
            tableView.reloadData()
        } else if anim == tableView.layer.animation(forKey: shrinkAnimationKey) {
            tableView.layer.removeAllAnimations()
            tableView.visibleCells.forEach({ $0.contentView.backgroundColor = self.menuBgColor })
            coverView.removeFromSuperview()
            removeFromSuperview()
        }
    }
    
    
    //MARK: 自定义单元格
    class MenuCell: UITableViewCell {
        
        let imageV = UIImageView()
        let label = UILabel()
        let divLine = UIView()
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            contentView.addSubview(imageV)
            contentView.addSubview(label)
            contentView.addSubview(divLine)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    /*＊箭头方向的枚举*/
    enum ArrowDirection {
        case up
        case down
        case left
        case right
    }
    
}



