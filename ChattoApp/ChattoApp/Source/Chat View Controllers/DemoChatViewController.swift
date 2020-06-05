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
import Chatto
import ChattoAdditions

final class CustomChatInputBar: UIView, ChatInputBarProtocol {
    var maxCharactersCount: UInt?


    var showsTextView: Bool = true
    var showsSendButton: Bool = true

    var inputText: String {
        get {
            inputTextView.text ?? ""
        }
        set {
            inputTextView.text = newValue
        }
    }

    public var inputTextView: UITextView {
        return self.textView
    }

    private let textView: ExpandableTextView = {
        return ExpandableTextView()
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        return button
    }()

    func setAppearance(_ appearance: ChatInputBarAppearance) {

    }

    var inputItems: [ChatInputItemProtocol] = [ChatInputItemProtocol]()

    weak var presenter: ChatInputBarPresenter?

    override init(frame: CGRect) {
        super.init(frame: frame)

        translatesAutoresizingMaskIntoConstraints = false
        let rootStackView = UIStackView()
        rootStackView.axis = .horizontal
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rootStackView)
        rootStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        rootStackView.addArrangedSubview(textView)
        rootStackView.addArrangedSubview(sendButton)

        self.textView.scrollsToTop = false
        self.textView.delegate = self
        self.textView.placeholderDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UITextViewDelegate
extension CustomChatInputBar: UITextViewDelegate {
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        return self.delegate?.inputBarShouldBeginTextEditing(self) ?? true
        return true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        self.presenter?.onDidEndEditing()
//        self.delegate?.inputBarDidEndEditing(self)
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        self.presenter?.onDidBeginEditing()
//        self.delegate?.inputBarDidBeginEditing(self)
    }

    public func textViewDidChange(_ textView: UITextView) {
//        self.updateSendButton()
//        self.delegate?.inputBarDidChangeText(self)
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
extension CustomChatInputBar: ExpandableTextViewPlaceholderDelegate {
    public func expandableTextViewDidShowPlaceholder(_ textView: ExpandableTextView) {
//        self.delegate?.inputBarDidShowPlaceholder(self)
    }

    public func expandableTextViewDidHidePlaceholder(_ textView: ExpandableTextView) {
//        self.delegate?.inputBarDidHidePlaceholder(self)
    }
}


class DemoChatViewController: BaseChatViewController {
    var shouldUseAlternativePresenter: Bool = false
    var shouldCenterInputItems: Bool = false

    var messageSender: DemoChatMessageSender!
    let messagesSelector = BaseMessagesSelector()

    var dataSource: DemoChatDataSource! {
        didSet {
            self.chatDataSource = self.dataSource
            self.messageSender = self.dataSource.messageSender
        }
    }

    lazy private var baseMessageHandler: BaseMessageHandler = {
        return BaseMessageHandler(messageSender: self.messageSender, messagesSelector: self.messagesSelector)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Chat"
        self.messagesSelector.delegate = self
        self.chatItemsDecorator = DemoChatItemsDecorator(messagesSelector: self.messagesSelector)
    }

    var chatInputPresenter: AnyObject!
    override func createChatInputView() -> UIView {
        //let chatInputView = ChatInputBar(frame: .zero)
        let chatInputView = CustomChatInputBar(frame: .zero)
        var appearance = ChatInputBarAppearance()
        appearance.sendButtonAppearance.title = NSLocalizedString("Send", comment: "")
        appearance.textInputAppearance.placeholderText = NSLocalizedString("Type a message", comment: "")
        if self.shouldUseAlternativePresenter {
            let chatInputPresenter = ExpandableChatInputBarPresenter(
                inputPositionController: self,
                chatInputBar: chatInputView,
                chatInputItems: self.createChatInputItems(),
                chatInputBarAppearance: appearance)
            self.chatInputPresenter = chatInputPresenter
            self.keyboardEventsHandler = chatInputPresenter
            self.scrollViewEventsHandler = chatInputPresenter
        } else {
            self.chatInputPresenter = BasicChatInputBarPresenter(chatInputBar: chatInputView, chatInputItems: self.createChatInputItems(), chatInputBarAppearance: appearance)
        }
        chatInputView.maxCharactersCount = 1000
        return chatInputView
    }

    override func createPresenterBuilders() -> [ChatItemType: [ChatItemPresenterBuilderProtocol]] {

        let textMessagePresenter = TextMessagePresenterBuilder(
            viewModelBuilder: self.createTextMessageViewModelBuilder(),
            interactionHandler: GenericMessageHandler(baseHandler: self.baseMessageHandler)
        )
        textMessagePresenter.baseMessageStyle = BaseMessageCollectionViewCellAvatarStyle()

        let photoMessagePresenter = PhotoMessagePresenterBuilder(
            viewModelBuilder: DemoPhotoMessageViewModelBuilder(),
            interactionHandler: GenericMessageHandler(baseHandler: self.baseMessageHandler)
        )
        photoMessagePresenter.baseCellStyle = BaseMessageCollectionViewCellAvatarStyle()

        let compoundPresenterBuilder = CompoundMessagePresenterBuilder(
            viewModelBuilder: DemoCompoundMessageViewModelBuilder(),
            interactionHandler: GenericMessageHandler(baseHandler: self.baseMessageHandler),
            accessibilityIdentifier: nil,
            contentFactories: [
                .init(DemoTextMessageContentFactory()),
                .init(DemoImageMessageContentFactory()),
                .init(DemoDateMessageContentFactory())
            ],
            compoundCellDimensions: .defaultDimensions,
            baseCellStyle: BaseMessageCollectionViewCellAvatarStyle()
        )

        return [
            DemoTextMessageModel.chatItemType: [textMessagePresenter],
            DemoPhotoMessageModel.chatItemType: [photoMessagePresenter],
            SendingStatusModel.chatItemType: [SendingStatusPresenterBuilder()],
            TimeSeparatorModel.chatItemType: [TimeSeparatorPresenterBuilder()],
            ChatItemType.compoundItemType: [compoundPresenterBuilder]
        ]
    }

    func createTextMessageViewModelBuilder() -> DemoTextMessageViewModelBuilder {
        return DemoTextMessageViewModelBuilder()
    }

    func createChatInputItems() -> [ChatInputItemProtocol] {
        var items = [ChatInputItemProtocol]()
        items.append(self.createTextInputItem())
        items.append(self.createPhotoInputItem())
        if self.shouldUseAlternativePresenter {
            items.append(self.customInputItem())
        }
        return items
    }

    private func createTextInputItem() -> TextChatInputItem {
        let item = TextChatInputItem()
        item.textInputHandler = { [weak self] text in
            self?.dataSource.addTextMessage(text)
        }
        return item
    }

    private func createPhotoInputItem() -> PhotosChatInputItem {
        let item = PhotosChatInputItem(presentingController: self)
        item.photoInputHandler = { [weak self] image, _ in
            self?.dataSource.addPhotoMessage(image)
        }
        return item
    }

    private func customInputItem() -> ContentAwareInputItem {
        let item = ContentAwareInputItem()
        item.textInputHandler = { [weak self] text in
            self?.dataSource.addTextMessage(text)
        }
        return item
    }
}

extension DemoChatViewController: MessagesSelectorDelegate {
    func messagesSelector(_ messagesSelector: MessagesSelectorProtocol, didSelectMessage: MessageModelProtocol) {
        self.enqueueModelUpdate(updateType: .normal)
    }

    func messagesSelector(_ messagesSelector: MessagesSelectorProtocol, didDeselectMessage: MessageModelProtocol) {
        self.enqueueModelUpdate(updateType: .normal)
    }
}

extension CompoundBubbleLayoutProvider.Dimensions {
    static var defaultDimensions: CompoundBubbleLayoutProvider.Dimensions {
        return .init(spacing: 8, contentInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
    }
}
