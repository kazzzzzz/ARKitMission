//
//  DrawView.swift
//  ARKitMission
//
//  Created by 水野一機 on 2021/04/28.
//

import ARKit

///描画するためのUIViewクラス
class DrawView: UIView {

    public var positions :[simd_float4] = []
    public var text : String = ""
    
    public override func draw(_ rect: CGRect) {
        
        let line = UIBezierPath()
        //原点位置をviewの真ん中にするため、self.frame.sizeの半分づつ移動させる
        let startPoint = CGPoint(x: CGFloat(self.positions[0].x) + self.frame.width/2, y: CGFloat(self.positions[0].y) + self.frame.height/2)
        line.move(to: startPoint)
        for i in 1 ..< positions.count {
            let point = CGPoint(x: CGFloat(self.positions[i].x) + self.frame.width/2, y: CGFloat(self.positions[i].y) + self.frame.height/2)
            line.addLine(to: point)
        }
        //ラインを結ぶ
        line.close()
        //色の設定
        UIColor.red.setStroke()
        //ライン幅
        line.lineWidth = 1
        
        //拡大・位置調整
        line.apply(CGAffineTransform(a: 31, b: 0, c: 0, d: 31, tx: -6200, ty: -12800))
        //描画
        line.stroke()
        
        self.text.draw(at: CGPoint(x: 10, y: self.frame.height - 100))
    }
}
