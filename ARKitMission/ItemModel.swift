//
//  ItemModel.swift
//  ARKitMission
//
//  Created by 水野一機 on 2021/05/11.
//

import ARKit

/// 計算処理やデータの保存などを行う
struct ItemModel {
    
    weak var vc: ViewController?
    
    /// 選択したアイテムの名前
    var selectedItem: String? = "plant"
    /// アイテムを配置した座標の配列
    var items: [simd_float4] = []
    /// 2点間の距離の配列
    var distances: [Float] = []
    /// 2点間距離のしきい値
    private let threshold: Float = 10.0
    /// nodeを配置するView
    private let sView: ARSCNView!
    
    init(view: ARSCNView) {
        self.sView = view
    }
    
    /// アイテムを配置する
    mutating func addItem(hitTestResult: ARHitTestResult) {
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
    mutating func removeItem(hitTestResult: SCNHitTestResult) {
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
    
    /// 次の画面に遷移する
    mutating func transition() {
        // アイテムが4つ以上、かつ最初と最後のアイテムの距離がしきい値未満のとき
        if (items.count > 3) && checkItemsDistance() {
            // 距離データを保存(ラベル出力用)
            for i in 0 ..< items.count - 1 {
                let d = calcDistance(start: items[i], end: items[i + 1])
                distances.append(d)
            }
            // sessionを中断
            sView.session.pause()
            vc?.segueNextVC()
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
