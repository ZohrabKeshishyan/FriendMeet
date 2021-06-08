//
//  SendBarView.swift
//  AFNetworking
//
//  Created by ben3 on 14/09/2020.
//

import Foundation
import KeepLayout
import NextGrowingTextView

public class SendBarView: UIView, UITextViewDelegate {
    
    public var textView: NextGrowingTextView?
    public let divider = UIView()

    public let startButtonsView = UIView()
    public var startActions = [SendBarAction]()

    public let endButtonsView = UIView()
    public var endActions = [SendBarAction]()
    
    public var sendAction: SendBarAction?
    public var audioEnabled = false
    public var micButtonEnabled = false
    public var blurEnabled = ChatKit.config().blurEnabled
    
    public var background: UIView?
    
    public var didBecomeFirstResponder: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    public convenience required init?(coder: NSCoder) {
        self.init()
    }

    public func setup() {
                
        textView = NextGrowingTextView()
        textView?.delegate = self
        textView?.textView.delegate = self
        textView?.textView.font = UIFont.systemFont(ofSize: 16)
        textView?.layer.cornerRadius = 10
        textView?.layer.borderWidth = 1
        textView?.isScrollEnabled = true
        textView?.maxNumberOfLines = ChatKit.config().sendBarMaxLines

        textView?.delegates.didChangeHeight = { [weak self] height in
            self?.textView?.keepHeight.equal = height
        }
        textView?.delegates.willChangeHeight = { height in
        }
        
        addSubview(divider)
        addSubview(startButtonsView)
        addSubview(textView!)
        addSubview(endButtonsView)
        
        divider.keepTopInset.equal = 0
        divider.keepLeftInset.equal = 0
        divider.keepRightInset.equal = 0
        divider.keepHeight.equal = KeepHigh(1)

        startButtonsView.keepTopInset.equal = ChatKit.config().sendBarViewTopPadding
        startButtonsView.keepLeftInset.equal = ChatKit.config().sendBarViewStartPadding
        startButtonsView.keepBottomInset.equal = ChatKit.config().sendBarViewBottomPadding
        startButtonsView.keepRightOffsetTo(textView!)?.equal = ChatKit.config().sendBarViewElementSpacing
        startButtonsView.keepWidth.equal = KeepHigh(0)

        endButtonsView.keepTopInset.equal = ChatKit.config().sendBarViewTopPadding
        endButtonsView.keepRightInset.equal = ChatKit.config().sendBarViewEndPadding
        endButtonsView.keepBottomInset.equal = ChatKit.config().sendBarViewBottomPadding
        endButtonsView.keepLeftOffsetTo(textView!)?.equal = ChatKit.config().sendBarViewElementSpacing
        endButtonsView.keepWidth.equal = KeepHigh(0)

        textView?.keepTopInset.equal = ChatKit.config().sendBarViewTopPadding
        textView?.keepBottomInset.equal = ChatKit.config().sendBarViewBottomPadding

        background = ChatKit.provider().makeBackground(blur: blurEnabled)
        insertSubview(background!, at: 0)
        background?.keepInsets.equal = 0
        background?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        background?.alpha = 0

        backgroundColor = .clear
        
        updateColors()

    }
    
    public func updateColors() {
        textView?.backgroundColor = ChatKit.asset(color: "gray_4")
        textView?.layer.borderColor = ChatKit.asset(color: "gray_6").cgColor
        divider.backgroundColor = ChatKit.asset(color: "gray_6")
    }
    
    public func setBackgroundAlpha(alpha: CGFloat) {
        background?.alpha = alpha
    }
        
    public func addActionToStart(action: SendBarAction) {
        startActions.append(action)
        layoutStartActions()
    }

    public func addActionToEnd(action: SendBarAction) {
        endActions.append(action)
        layoutEndActions()
    }
    
    public func removeActionFromStart(at: Int) {
        clearLayout(actions: startActions)
        startActions.remove(at: at)
        layoutStartActions()
    }

    public func removeActionFromEnd(at: Int) {
        clearLayout(actions: endActions)
        endActions.remove(at: at)
        layoutEndActions()
    }

    public func clearLayout(actions: [SendBarAction]) {
        for action in actions {
            let button = action.getButton()
            button.removeFromSuperview()
        }
    }
    
    public func resetLayout(actions: [SendBarAction]) {
        for action in actions {
            let button = action.getButton()

            button.removeFromSuperview()
            addSubview(button)
            
            button.keepTopInset.min = ChatKit.config().sendBarViewTopPadding
            button.keepBottomInset.min = ChatKit.config().sendBarViewBottomPadding
            button.keepVerticallyCentered()
        }
    }
        
    public func filterActions(actions: [SendBarAction], hasText: Bool) -> [SendBarAction] {
        var result = [SendBarAction]()
        
        for action in actions {
            if action.visibility == .always {
                result.append(action)
            }
            if action.visibility == .noText && !hasText {
                result.append(action)
            }
            if action.visibility == .text && hasText {
                result.append(action)
            }
            // If this is filtered out, hide it
            action.getButton().alpha = result.contains(action) ? 1 : 0
        }
        return result
    }
    
    public func layoutStartActions(hasText: Bool = false) {
        resetLayout(actions: startActions)

        let actions = filterActions(actions: startActions, hasText: hasText)
        
//        if actions.isEmpty {
//            startButtonsView.keepWidth.equal = 0
//        } else {
//            startButtonsView.keepWidth.equal = KeepLow(0)
//        }

        for action in startActions {
            if !actions.contains(action) {
                action.getButton().keepLeftInset.equal = ChatKit.config().sendBarViewStartPadding
            }
        }

        actions.first?.getButton().keepLeftInset.equal = ChatKit.config().sendBarViewStartPadding
        actions.last?.getButton().keepRightOffsetTo(textView)?.equal = ChatKit.config().sendBarViewElementSpacing

        var previousAction = actions.first
        for action in actions {
            if !action.isEqual(previousAction) {
                action.button?.keepLeftOffsetTo(previousAction?.button)?.equal = ChatKit.config().sendBarViewElementSpacing
            }
            previousAction = action
        }
    }
    
    public func layoutEndActions(hasText: Bool = false) {
        resetLayout(actions: endActions)
        
        let actions = filterActions(actions: endActions, hasText: hasText)

        for action in endActions {
            if !actions.contains(action) {
                action.getButton().keepRightInset.equal = ChatKit.config().sendBarViewEndPadding
            }
        }
        
        actions.last?.getButton().keepRightInset.equal = ChatKit.config().sendBarViewEndPadding
        actions.first?.getButton().keepLeftOffsetTo(textView)?.equal = ChatKit.config().sendBarViewElementSpacing
        
        var previousAction = actions.first
        for action in actions {
            if !action.isEqual(previousAction) {
                action.button?.keepLeftOffsetTo(previousAction?.button)?.equal = ChatKit.config().sendBarViewElementSpacing
            }
            previousAction = action
        }
    }
    
    public func addAction(_ action: SendBarAction) {
        sendAction = action
        if action.position == .end {
            addActionToEnd(action: action)
        } else {
            addActionToStart(action: action)
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let old = textView.text as NSString?
        if let newText = old?.replacingCharacters(in: range, with: text) {
            if newText.isEmptyOrBlank() != textView.text.isEmptyOrBlank() {
                layout(hasText: !newText.isEmpty)
            }
        }
        return true
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        didBecomeFirstResponder?()
    }
    
    public func layout(hasText: Bool = false) {
        keepAnimated(withDuration: 0.2, delay: 0, options: .curveEaseInOut, layout: { [weak self] in
            self?.layoutStartActions(hasText: hasText)
            self?.layoutEndActions(hasText: hasText)
        }, completion: nil)
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        if hasText() {
            
        } else {
            
        }
    }
    
    public func text() -> String? {
        return textView?.textView.text
    }
    
    public func hasText() -> Bool {
        if let text = text(), text.hasText() {
            return true
        }
        return false
    }

    public func hide() {
        textView?.textView.resignFirstResponder()
    }

    public func show() {
        textView?.textView.becomeFirstResponder()
    }

    public func hideAndDisable() {
        setDisabled(value: true)
        hide()
    }
    
    public func setDisabled(value: Bool) {
        textView?.textView.isEditable = !value
        for action in startActions {
            action.getButton().isEnabled = !value
        }
        for action in endActions {
            action.getButton().isEnabled = !value
        }
    }
    
    public func clear() {
        textView?.textView.text = ""
    }
}

extension String {
    public func isEmptyOrBlank() -> Bool {
        return replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "").isEmpty
    }
    public func hasText() -> Bool {
        return !isEmptyOrBlank()
    }
}

