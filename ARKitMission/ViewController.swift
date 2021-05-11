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
        model.vc = self
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
        // 次の画面に遷移
        model.transition()
    }
    
    @objc func onLongTap(sender: UILongPressGestureRecognizer) {
        guard  sender.state == .began else { return }
        
        let results = sceneView.hitTest(sender.location(in: sceneView))
        
        if let result = results.first {
            // アイテムを削除
            model.removeItem(hitTestResult: result)
        }
    }
    
    /// NextViewControllerに遷移する
    func segueNextVC() {
        // メインスレッドで行う
        DispatchQueue.main.async {
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "toNext") as? NextViewController
            if let nextVC = nextVC {
                nextVC.model = self.model
                self.present(nextVC, animated: true, completion: nil)
            }
        }
    }
}
