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
        
        //カメラロールに保存
        save()
    }
    
    // viewをimageに変換しカメラロールに保存する
    private func save() {
        // viewをimageとして取得
        let image : UIImage = drawView.convertToImage()
        
        // カメラロールに保存する
        UIImageWriteToSavedPhotosAlbum(image,self,#selector(self.didFinishSavingImage(_:didFinishSavingWithError:contextInfo:)),
                                       nil)
    }
    
    // 保存を試みた結果を受け取る
    @objc func didFinishSavingImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        
        // 結果によって出すアラートを変更する
        var title = "保存完了"
        var message = "カメラロールに保存しました"
        
        if error != nil {
            title = "エラー"
            message = "保存に失敗しました"
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
