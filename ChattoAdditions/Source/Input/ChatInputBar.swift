/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

import UIKit

public protocol ChatInputBarDelegate: class {
    func inputBarShouldBeginTextEditing(_ inputBar: ChatInputBar) -> Bool
    func inputBarDidBeginEditing(_ inputBar: ChatInputBar)
    func inputBarDidEndEditing(_ inputBar: ChatInputBar)
    func inputBarDidChangeText(_ inputBar: ChatInputBar)
    func inputBarSendButtonPressed(_ inputBar: ChatInputBar)
    func inputBar(_ inputBar: ChatInputBar, shouldFocusOnItem item: ChatInputItemProtocol) -> Bool
    func inputBar(_ inputBar: ChatInputBar, didLoseFocusOnItem item: ChatInputItemProtocol)
    func inputBar(_ inputBar: ChatInputBar, didReceiveFocusOnItem item: ChatInputItemProtocol)
    func inputBarDidShowPlaceholder(_ inputBar: ChatInputBar)
    func inputBarDidHidePlaceholder(_ inputBar: ChatInputBar)
}

public protocol ChatInputBarProtocol: UIView {
    var showsTextView: Bool { get set }
    var showsSendButton: Bool { get set }
    var inputText: String { get set }
    var inputTextView: UITextView { get }
    func setAppearance(_ appearance: ChatInputBarAppearance)
    var inputItems: [ChatInputItemProtocol] { get set }
    var presenter: ChatInputBarPresenter? { get set } // make this weak
    var maxCharactersCount: UInt? { get set } // nil -> unlimited
}

open class ChatInputBar: UIView, ChatInputBarProtocol {

    public var pasteActionInterceptor: PasteActionInterceptor? {
        get { return self.textView.pasteActionInterceptor }
        set { self.textView.pasteActionInterceptor = newValue }
    }

    public weak var delegate: ChatInputBarDelegate?
    weak public var presenter: ChatInputBarPresenter?

    public var shouldEnableSendButton = { (inputBar: ChatInputBar) -> Bool in
        return !inputBar.textView.text.isEmpty
    }

    public var inputTextView: UITextView {
        return self.textView
    }

    let scrollView: HorizontalStackScrollView = {
        return HorizontalStackScrollView()
    }()

    let textView: ExpandableTextView = {
        return ExpandableTextView()
    }()

    let sendButton: UIButton = {
        return UIButton(type: .custom)
    }()

    let topBorderView: UIView = {
        let topBorderView = UIView()
        topBorderView.translatesAutoresizingMaskIntoConstraints = false
        topBorderView.backgroundColor = UIColor(white: 0.6, alpha: 1)
        return topBorderView
    }()

    private var tabbBarHeightConstraint: NSLayoutConstraint!

    public override init(frame: CGRect) {
        super.init(frame: frame)

        translatesAutoresizingMaskIntoConstraints = false
        let rootStackView = UIStackView()
        rootStackView.axis = .vertical
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rootStackView)
        rootStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        rootStackView.addArrangedSubview(topBorderView)
        rootStackView.addArrangedSubview(textView)

        let scrollViewSendButtonStackView = UIStackView(arrangedSubviews: [scrollView, sendButton])
        scrollViewSendButtonStackView.axis = .horizontal
        rootStackView.addArrangedSubview(scrollViewSendButtonStackView)

        tabbBarHeightConstraint =  scrollView.heightAnchor.constraint(equalToConstant: 44)
        tabbBarHeightConstraint.isActive = true

        self.topBorderView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
        self.textView.scrollsToTop = false
        self.textView.delegate = self
        self.textView.placeholderDelegate = self
        self.scrollView.scrollsToTop = false
        self.sendButton.isEnabled = false
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open var showsTextView: Bool = true {
        didSet {
            textView.isHidden = !showsTextView
            self.updateIntrinsicContentSizeAnimated()
        }
    }

    open var showsSendButton: Bool = true {
        didSet {
            sendButton.isHidden = !showsSendButton
            self.updateIntrinsicContentSizeAnimated()
        }
    }

    public var maxCharactersCount: UInt? // nil -> unlimited

    private func updateIntrinsicContentSizeAnimated() {
        let options: UIView.AnimationOptions = [.beginFromCurrentState, .allowUserInteraction]
        UIView.animate(withDuration: 0.25, delay: 0, options: options, animations: { () -> Void in
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
        }, completion: nil)
    }

    public var inputItems = [ChatInputItemProtocol]() {
        didSet {
            let inputItemViews = self.inputItems.map { (item: ChatInputItemProtocol) -> ChatInputItemView in
                let inputItemView = ChatInputItemView()
                inputItemView.inputItem = item
                inputItemView.delegate = self
                return inputItemView
            }
            self.scrollView.addArrangedViews(inputItemViews)
        }
    }

    open func becomeFirstResponderWithInputView(_ inputView: UIView?) {
        self.textView.inputView = inputView

        if self.textView.isFirstResponder {
            self.textView.reloadInputViews()
        } else {
            self.textView.becomeFirstResponder()
        }
    }

    public var inputText: String {
        get {
            return self.textView.text
        }
        set {
            self.textView.text = newValue
            self.updateSendButton()
        }
    }

    public var inputSelectedRange: NSRange {
        get {
            return self.textView.selectedRange
        }
        set {
            self.textView.selectedRange = newValue
        }
    }

    public var placeholderText: String {
        get {
            return self.textView.placeholderText
        }
        set {
            self.textView.placeholderText = newValue
        }
    }

    fileprivate func updateSendButton() {
        self.sendButton.isEnabled = self.shouldEnableSendButton(self)
    }

    @IBAction func buttonTapped(_ sender: AnyObject) {
        self.presenter?.onSendButtonPressed()
        self.delegate?.inputBarSendButtonPressed(self)
    }

    public func setTextViewPlaceholderAccessibilityIdentifer(_ accessibilityIdentifer: String) {
        self.textView.setTextPlaceholderAccessibilityIdentifier(accessibilityIdentifer)
    }
}

// MARK: - ChatInputItemViewDelegate
extension ChatInputBar: ChatInputItemViewDelegate {
    func inputItemViewTapped(_ view: ChatInputItemView) {
        self.focusOnInputItem(view.inputItem)
    }

    public func focusOnInputItem(_ inputItem: ChatInputItemProtocol) {
        let shouldFocus = self.delegate?.inputBar(self, shouldFocusOnItem: inputItem) ?? true
        guard shouldFocus else { return }

        let previousFocusedItem = self.presenter?.focusedItem
        self.presenter?.onDidReceiveFocusOnItem(inputItem)

        if let previousFocusedItem = previousFocusedItem {
            self.delegate?.inputBar(self, didLoseFocusOnItem: previousFocusedItem)
        }
        self.delegate?.inputBar(self, didReceiveFocusOnItem: inputItem)
    }
}

// MARK: - ChatInputBarAppearance
extension ChatInputBar {
    public func setAppearance(_ appearance: ChatInputBarAppearance) {
        self.textView.font = appearance.textInputAppearance.font
        self.textView.textColor = appearance.textInputAppearance.textColor
        self.textView.tintColor = appearance.textInputAppearance.tintColor
        self.textView.textContainerInset = appearance.textInputAppearance.textInsets
        self.textView.setTextPlaceholderFont(appearance.textInputAppearance.placeholderFont)
        self.textView.setTextPlaceholderColor(appearance.textInputAppearance.placeholderColor)
        self.textView.placeholderText = appearance.textInputAppearance.placeholderText
        self.textView.layer.borderColor = appearance.textInputAppearance.borderColor.cgColor
        self.textView.layer.borderWidth = appearance.textInputAppearance.borderWidth
        self.textView.accessibilityIdentifier = appearance.textInputAppearance.accessibilityIdentifier
        self.tabBarInterItemSpacing = appearance.tabBarAppearance.interItemSpacing
        self.tabBarContentInsets = appearance.tabBarAppearance.contentInsets
        self.sendButton.contentEdgeInsets = appearance.sendButtonAppearance.insets
        self.sendButton.setTitle(appearance.sendButtonAppearance.title, for: .normal)
        appearance.sendButtonAppearance.titleColors.forEach { (state, color) in
            self.sendButton.setTitleColor(color, for: state.controlState)
        }
        self.sendButton.titleLabel?.font = appearance.sendButtonAppearance.font
        self.sendButton.accessibilityIdentifier = appearance.sendButtonAppearance.accessibilityIdentifier
        self.tabbBarHeightConstraint.constant = appearance.tabBarAppearance.height
    }
}

extension ChatInputBar { // Tabar
    public var tabBarInterItemSpacing: CGFloat {
        get {
            return self.scrollView.interItemSpacing
        }
        set {
            self.scrollView.interItemSpacing = newValue
        }
    }

    public var tabBarContentInsets: UIEdgeInsets {
        get {
            return self.scrollView.contentInset
        }
        set {
            self.scrollView.contentInset = newValue
        }
    }
}

// MARK: UITextViewDelegate
extension ChatInputBar: UITextViewDelegate {
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return self.delegate?.inputBarShouldBeginTextEditing(self) ?? true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        self.presenter?.onDidEndEditing()
        self.delegate?.inputBarDidEndEditing(self)
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        self.presenter?.onDidBeginEditing()
        self.delegate?.inputBarDidBeginEditing(self)
    }

    public func textViewDidChange(_ textView: UITextView) {
        self.updateSendButton()
        self.delegate?.inputBarDidChangeText(self)
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn nsRange: NSRange, replacementText text: String) -> Bool {
        guard let maxCharactersCount = self.maxCharactersCount else { return true }
        let currentText: NSString = textView.text as NSString
        let currentCount = currentText.length
        let rangeLength = nsRange.length
        let nextCount = currentCount - rangeLength + (text as NSString).length
        return UInt(nextCount) <= maxCharactersCount
    }

}

// MARK: ExpandableTextViewPlaceholderDelegate
extension ChatInputBar: ExpandableTextViewPlaceholderDelegate {
    public func expandableTextViewDidShowPlaceholder(_ textView: ExpandableTextView) {
        self.delegate?.inputBarDidShowPlaceholder(self)
    }

    public func expandableTextViewDidHidePlaceholder(_ textView: ExpandableTextView) {
        self.delegate?.inputBarDidHidePlaceholder(self)
    }
}
