//
//  NextViewController.swift
//  ARKitMission
//
//  Created by 水野一機 on 2021/04/28.
//

import ARKit

class NextViewController: UIViewController {
    //図形を描画する画面
    @IBOutlet weak var imageView: UIView!
    
    private let drawView = DrawView()
    
    public var positions:[simd_float4] = []
    public var distances:[Float] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //画像に記載する文字列を作成
        var text : String = ""
        let endNum = distances.count - 1
        for i in 0 ..< endNum {
            text += "\(i+1)と\(i+2)の距離:\(distances[i])\n"
            print(distances.count)
        }
        text += "\(distances.count)と1の距離:\(distances[endNum])"
        drawView.text = text
        
        //画像に絵を描画
        drawView.positions = positions
        
        drawView.backgroundColor = UIColor.white
        drawView.frame = CGRect(x: 0,
                             y: 0,
                             width: self.imageView.frame.width,
                             height: self.imageView.frame.height)
        self.imageView.addSubview(drawView)
    }
    

}
