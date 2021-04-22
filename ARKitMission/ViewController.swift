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
    }
    
    @objc func onTap(sender: UITapGestureRecognizer) {
        
        let results = sceneView.hitTest(sender.location(in: sceneView),types: .featurePoint)
        guard !results.isEmpty else { return }
        if let result = results.first {
            let anchor = ARAnchor(name: "plantAnchor",
                                  transform: result.worldTransform)
            // ARセッションにanchorを追加
            sceneView.session.add(anchor: anchor)
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

