//
//  NextViewController.swift
//  ARKitMission
//
//  Created by 水野一機 on 2021/04/28.
//

import ARKit

class NextViewController: UIViewController {
    // 図形を描画する画面
    @IBOutlet private weak var imageView: DrawView!

    var model: ItemModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.model = model
        
        imageView.backgroundColor = UIColor.white
        // カメラロールに保存
        save()
    }
    
    // viewをimageに変換しカメラロールに保存する
    private func save() {
        // viewをimageとして取得
        let image: UIImage = imageView.convertToImage()
        
        // カメラロールに保存する
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.didFinishSavingImage(_: didFinishSavingWithError: contextInfo: )),
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
