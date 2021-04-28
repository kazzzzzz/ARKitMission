//
//  UIView.swift
//  ARKitMission
//
//  Created by 水野一機 on 2021/04/28.
//

import UIKit

public extension UIView {
    ///UIViewをUIImageに変換
    func convertToImage() -> UIImage {
       let imageRenderer = UIGraphicsImageRenderer.init(size: bounds.size)
        return imageRenderer.image { context in
            layer.render(in: context.cgContext)
        }
    }
}
