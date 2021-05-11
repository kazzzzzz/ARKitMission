//
//  DrawView.swift
//  ARKitMission
//
//  Created by 水野一機 on 2021/04/28.
//

import ARKit

/// 描画するためのUIViewクラス
class DrawView: UIView {
    
    var text: String = ""
    var model: ItemModel!
    
    override func draw(_ rect: CGRect) {
        
        let items = model.items
        let line = UIBezierPath()
        // 原点位置をviewの真ん中にするため、self.frame.sizeの半分づつ移動させる
        let startPoint = CGPoint(x: CGFloat(items[0].x) + self.frame.width / 2, y: CGFloat(items[0].y) + self.frame.height / 2)
        line.move(to: startPoint)
        for i in 1 ..< items.count {
            let point = CGPoint(x: CGFloat(items[i].x) + self.frame.width / 2, y: CGFloat(items[i].y) + self.frame.height / 2)
            line.addLine(to: point)
        }
        line.close()
        UIColor.red.setStroke()
        line.lineWidth = 1
        
        line.apply(CGAffineTransform(a: 31, b: 0, c: 0, d: 31, tx: -6200, ty: -12800))
        line.stroke()
        
        self.text.draw(at: CGPoint(x: 10, y: self.frame.height - 100))
    }
}
