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
    
    var selectedItem: String? = "plant"
    
    /// objectを配置する際にタップした座標の配列
    private var positions: [simd_float4] = []
    /// 2点間の距離を保存しておく配列
    private var distances: [Float] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.scene = SCNScene()
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

        sceneView.autoenablesDefaultLighting = true
        
        sceneView.delegate = self
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
            addItem(hitTestResult: result)
        }
        
        // positionが4つ以上の時
        if positions.count > 3 {
            
            let startPos = positions[0]
            let endPos = positions[positions.count - 1]
            
            // 最初の座標と最後の座標の距離
            let distance = calcDistance(start: startPos, end: endPos)
            
            // distanceが一定値未満になったときに終了する
            if distance < 10 {
                // 2点間の距離を計算し、データを保存する
                for i in 0 ..< positions.count - 1 {
                    let posDistance = calcDistance(start: positions[i], end: positions[i + 1])
                    distances.append(posDistance)
                }
                // sessionを中断
                sceneView.session.pause()
                // メインスレッドで行う
                DispatchQueue.main.async {
                    // NextViewontrollerに遷移
                    let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "toNext") as? NextViewController
                    if let nextVC = nextVC {
                        nextVC.positions = self.positions
                        nextVC.distances = self.distances
                        self.present(nextVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @objc func onLongTap(sender: UILongPressGestureRecognizer) {
        // ロングタップ中かどうか
        guard  sender.state == .began else { return }
        
        let results = sceneView.hitTest(sender.location(in: sceneView))
        
        if let result = results.first {
            let transform = result.modelTransform
            guard result.node.parent!.name == selectedItem else { return }
            
            for i in 0 ..< positions.count {
                // onTap時のhitTest結果とlongTap時のhitTest結果の座標が等しいかどうか
                if (positions[i].x == transform.m41) && (positions[i].y == transform.m42) && (positions[i].z == transform.m43) {
                    
                    // positionsから削除
                    positions.remove(at: i)
                    // nodeからオブジェクトを削除
                    result.node.parent!.removeFromParentNode()
                    break
                }
            }
        }
    }
    
    // 2点間距離の計算
    private func calcDistance(start: simd_float4, end: simd_float4) -> Float {
        let d: Float
        let pos = SCNVector3Make(end.x - start.x,
                                 end.y - start.y,
                                 end.z - start.z)
        d = sqrt(pos.x * pos.x + pos.y * pos.y + pos.z * pos.z )
        return d
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
            
            // 3Dモデルを配置
            node.position = SCNVector3(x: thirdColumn.x,
                                       y: thirdColumn.y,
                                       z: thirdColumn.z)
            
            node.scale = SCNVector3(0.005, 0.005, 0.005)
            
            node.name = selectedItem
            
            // シーンに追加
            sceneView.scene.rootNode.addChildNode(node)
            
            // 配列に追加
            positions.append(thirdColumn)
        }
    }
}
