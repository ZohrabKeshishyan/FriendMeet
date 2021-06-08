//
//  SendSendBarAction.swift
//  ChatK!t
//
//  Created by ben3 on 18/04/2021.
//

import Foundation

public class SendBarActions {
    
    public static func camera(onClick: @escaping (() -> Void)) -> SendBarAction {
        return SendBarAction(image: ChatKit.asset(icon: "icn_30_camera"), action: onClick, visibility: .noText, position: .end)
    }

    public static func plus(onClick: @escaping (() -> Void)) -> SendBarAction {
        return SendBarAction(image: ChatKit.asset(icon: "icn_30_plus"), action: onClick, visibility: .always, position: .start)
    }

    public static func mic(onClick: @escaping (() -> Void)) -> SendBarAction {
        return SendBarAction(image: ChatKit.asset(icon: "icn_30_mic"), action: onClick, visibility: .noText, position: .end)
    }

    public static func send(onClick: @escaping (() -> Void)) -> SendBarAction {
        return SendBarAction(image: ChatKit.asset(icon: "icn_30_send"), action: onClick, visibility: .text, position: .end)
    }

}
