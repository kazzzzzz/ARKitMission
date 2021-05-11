//
//  ViewController.swift
//  ARKitMission
//
//  Created by 水野一機 on 2021/04/22.
//

import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet private weak var sceneView: ARSCNView!
    
    var model: ItemModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.scene = SCNScene()
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
        sceneView.delegate = self
        
        model = ItemModel(view: sceneView)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        // タップハンドラの登録
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.sceneView.addGestureRecognizer(gesture)
        
        // ロングタップハンドラの登録
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongTap))
        self.sceneView.addGestureRecognizer(longTapGesture)
    }
    
    @objc func onTap(sender: UITapGestureRecognizer) {
        
        let results = sceneView.hitTest(sender.location(in: sceneView), types: .featurePoint)
        guard !results.isEmpty else { return }
        if let result = results.first {
            model.addItem(hitTestResult: result)
        }
        
        // アイテムが4つ以上、かつ最初と最後のアイテムの距離がしきい値未満のとき
        if (model.items.count > 3) && model.checkItemsDistance() {
            // 距離データを保存
            model.saveDistance()
            // sessionを中断
            sceneView.session.pause()
            // メインスレッドで行う
            DispatchQueue.main.async {
                // NextViewontrollerに遷移
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "toNext") as? NextViewController
                if let nextVC = nextVC {
                    nextVC.model = self.model
                    self.present(nextVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func onLongTap(sender: UILongPressGestureRecognizer) {
        guard  sender.state == .began else { return }
        
        let results = sceneView.hitTest(sender.location(in: sceneView))
        
        if let result = results.first {
            // アイテムを削除
            model.removeItem(hitTestResult: result)
        }
    }
}

/// 計算処理やデータの保存などを行うクラス
class ItemModel {
    /// 選択したアイテムの名前
    var selectedItem: String? = "plant"
    /// アイテムを配置した座標の配列
    var items: [simd_float4] = []
    /// 2点間の距離の配列
    var distances: [Float] = []
    
    /// 2点間距離のしきい値
    let threshold: Float = 10.0
    
    let sView: ARSCNView!
    
    init(view: ARSCNView) {
        self.sView = view
    }
    
    /// アイテムを配置する
    func addItem(hitTestResult: ARHitTestResult) {
        if let selectedItem = self.selectedItem {
            // scnファイルから3Dモデルのノードを作成
            let scene = SCNScene(named: "\(selectedItem).scn",
                                 inDirectory: "Models.scnassets")
            let node = (scene?.rootNode.childNode(withName: selectedItem,
                                                  recursively: false))!
            
            let transform = hitTestResult.worldTransform
            let thirdColumn = transform.columns.3
            
            // 配列に追加
            items.append(thirdColumn)
            
            // 3Dモデルを配置
            node.position = SCNVector3(x: thirdColumn.x,
                                       y: thirdColumn.y,
                                       z: thirdColumn.z)
            
            node.scale = SCNVector3(0.005, 0.005, 0.005)
            
            node.name = selectedItem
            
            // シーンに追加
            sView.scene.rootNode.addChildNode(node)
        }
    }
    
    /// アイテムを削除する
    func removeItem(hitTestResult: SCNHitTestResult) {
        let transform = hitTestResult.modelTransform
        if hitTestResult.node.parent?.name == selectedItem {
            for i in 0 ..< items.count {
                // itemsの座標と等しいかどうか
                if (items[i].x == transform.m41) && (items[i].y == transform.m42) && (items[i].z == transform.m43) {
                    items.remove(at: i)
                    hitTestResult.node.parent?.removeFromParentNode()
                    break
                }
            }
        }
    }
    
    /// アイテム間の距離がしきい値未満かどうか
    func checkItemsDistance() -> Bool {
        // 最初のアイテム
        let sItem = items[0]
        // 最後のアイテム
        let eItem = items[items.count - 1]
        
        let distance = calcDistance(start: sItem, end: eItem)
        return distance < threshold
    }
    
    // 距離の値を保存(ラベル出力用)
    func saveDistance() {
        for i in 0 ..< items.count - 1 {
            let d = calcDistance(start: items[i], end: items[i + 1])
            distances.append(d)
        }
    }
    
    /// 2点間距離の計算
    func calcDistance(start: simd_float4, end: simd_float4) -> Float {
        let d: Float
        let pos = SCNVector3Make(end.x - start.x,
                                 end.y - start.y,
                                 end.z - start.z)
        d = sqrt(pos.x * pos.x + pos.y * pos.y + pos.z * pos.z )
        return d
    }
}
