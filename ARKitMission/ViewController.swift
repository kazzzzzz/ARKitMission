//
//  ViewController.swift
//  ARKitMission
//
//  Created by 水野一機 on 2021/04/22.
//

import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    /// objectを配置する際にタップした座標の配列
    private var positions : [simd_float4] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.scene = SCNScene()
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

        sceneView.autoenablesDefaultLighting = true;
        
        sceneView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
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
        
        let results = sceneView.hitTest(sender.location(in: sceneView),types: .featurePoint)
        guard !results.isEmpty else { return }
        if let result = results.first {
            // hitTestの結果をワールド座標系に変換
            let transform = result.worldTransform
            let anchor = ARAnchor(name: "plantAnchor",
                                  transform: transform)
            // ARセッションにanchorを追加
            sceneView.session.add(anchor: anchor)
            
            let position = transform.columns.3
            positions.append(position)
        }
    }
    
    @objc func onLongTap(sender: UILongPressGestureRecognizer) {
        // ロングタップ中かどうか
        guard  sender.state == .began else { return }
        
        let results = sceneView.hitTest(sender.location(in: sceneView))
        
        if let result = results.first {
            // hitTestの結果のnodeをワールド座標系に変換した行列
            let transform = result.modelTransform
            
            // 子nodeのなまえが"plant"かどうか
            guard result.node.parent!.name == "plant" else { return }
    
            for i in 0 ..< positions.count {
                //onTap時のhitTest結果とlongTap時のhitTest結果の座標が等しいかどうか
                if (positions[i].x == transform.m41) && (positions[i].y == transform.m42) && (positions[i].z == transform.m43) {
                    
                    // positionsから削除
                    positions.remove(at: i)
                    // nodeからオブジェクトを削除
                    result.node.parent!.removeFromParentNode()
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor.name == "plantAnchor" else { return }
        // scnデータを、映像を作るための変数sceneに格納
        guard let scene = SCNScene(named: "plant.scn",
                                   inDirectory: "Models.scnassets") else { return }
        // sceneの中の"plant"データのみを取り出して変数plantNodeに格納
        let plantNode = (scene.rootNode.childNode(withName: "plant",
                                                  recursively: false))!
        // 倍率を変更
        plantNode.scale = SCNVector3(0.005, 0.005, 0.005)
        // plantNodeを配置
        node.addChildNode(plantNode)
    }
}

