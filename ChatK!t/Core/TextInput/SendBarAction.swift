//
//  SendBarAction.swift
//  AFNetworking
//
//  Created by ben3 on 16/09/2020.
//

import Foundation
import KeepLayout


public class SendBarAction: NSObject {

    public enum Visibility {
        case always
        case text
        case noText
    }
    
    public enum Position {
        case start
        case end
    }

    let action: (()->Void)
    var text: String?
    var image: UIImage?
    var size: CGSize?
    var visibility: Visibility
    var position: Position
    var keyboardOverlay: String?
    public var color: UIColor?
    
    var button: UIButton?
        
    public init(text: String, action: @escaping (() -> Void), color: UIColor? = nil, visibility: Visibility = .always, position: Position = .end, keyboardOverlay: String? = nil) {
        self.action = action
        self.position = position
        self.text = text
        self.visibility = visibility
        self.keyboardOverlay = keyboardOverlay
        if let color = color {
            self.color = color
        } else {
            self.color = ChatKit.asset(color: "text_input_button")
        }
        super.init()
    }

    public init(image: UIImage, action: @escaping (() -> Void), size: CGSize = CGSize(width: 30, height: 30), color: UIColor? = nil, visibility: Visibility = .always, position: Position = .end, keyboardOverlay: String? = nil) {
        self.action = action
        self.image = image.withRenderingMode(.alwaysTemplate)
        self.position = position
        self.size = size
        self.visibility = visibility
        self.keyboardOverlay = keyboardOverlay
        if let color = color {
            self.color = color
        } else {
            self.color = ChatKit.asset(color: "text_input_button")
        }
        super.init()
    }
    
    public func getButton() -> UIButton {
        if let button = button {
            return button
        }

        button = image != nil ? UIButton(type: .custom) : UIButton()
        if let image = self.image {
            button!.setImage(image, for: .normal)
            button!.keepWidth.equal = size!.width
            button!.keepHeight.equal = KeepLow(size!.height)
            button!.tintColor = color
        }
        if let text = self.text {
            button!.setTitle(text, for: .normal)
            button!.setTitleColor(color, for: .normal)
            button!.keepWidth.equal = button!.intrinsicContentSize.width
            button!.keepHeight.equal = button!.intrinsicContentSize.height
            button!.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        }
        
        button!.addTarget(self, action: #selector(execute), for: .touchUpInside)
        
        return button!
    }

    @objc public func execute() {
        action()
    }
    
}
