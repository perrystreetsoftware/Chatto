//
// The MIT License (MIT)
//
// Copyright (c) 2015-present Badoo Trading Limited.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Foundation

public final class ReplyView: UIView {
    public var viewModel: MessageViewModelProtocol! {
        didSet {
            self.updateViews()
        }
    }

    static let emptyPhotoMessageModel = PhotoMessageModel(messageModel: MessageModel(uid: "", senderId: "", type: "replyBubbleType", isIncoming: true, date: Date(), status: .success), imageSize: .zero, image: UIImage(systemName: "star")!)

    static var emptyPhotoMessageViewModel: MessageViewModelProtocol {
        PhotoMessageViewModel(photoMessage: emptyPhotoMessageModel,
                              messageViewModel: MessageViewModel(dateFormatter: MessageViewModelDefaultBuilder.dateFormatter,
                                                                 messageModel: emptyTextMessageModel,
                                                                 avatarImage: nil,
                                                                 decorationAttributes: BaseMessageDecorationAttributes()))
    }

    static let emptyTextMessageModel = TextMessageModel(messageModel: MessageModel(uid: "", senderId: "", type: "replyBubbleType", isIncoming: true, date: Date(), status: .success), text: "")

    static var emptyTextMessageViewModel: MessageViewModelProtocol {
        TextMessageViewModel(textMessage: emptyTextMessageModel, messageViewModel: MessageViewModel(dateFormatter: MessageViewModelDefaultBuilder.dateFormatter,
                                                                                                                                    messageModel: emptyTextMessageModel,
                                                                                                                                    avatarImage: nil,
                                                                                                                                    decorationAttributes: BaseMessageDecorationAttributes()))
    }

    private lazy var photoBubbleView: PhotoBubbleView = {
        let bubbleView = PhotoBubbleView()
        bubbleView.photoMessageViewModel = ReplyPhotoMessageViewModel(messageViewModel: Self.emptyPhotoMessageViewModel)
        bubbleView.photoMessageStyle = ReplyPhotoStyle()

        return bubbleView
    }()

    private lazy var textBubbleView: TextBubbleView = {
        let bubbleView = TextBubbleView()
        bubbleView.layoutCache = NSCache<AnyObject, AnyObject>()
        bubbleView.textMessageViewModel = ReplyTextViewModel(messageViewModel: Self.emptyTextMessageViewModel)
        bubbleView.style = TextMessageCollectionViewCellDefaultStyle(
            bubbleImages: TextMessageCollectionViewCellDefaultStyle.createDefaultBubbleImages(),
            textStyle: TextMessageCollectionViewCellDefaultStyle.TextStyle(
                font: UIFont.systemFont(ofSize: 12),
                incomingColor: UIColor.black,
                outgoingColor: UIColor.white,
                incomingInsets: UIEdgeInsets(top: 10, left: 19, bottom: 10, right: 15),
                outgoingInsets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 19)
            ),
            baseStyle: BaseMessageCollectionViewCellDefaultStyle()
        )

        return bubbleView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        self.addSubview(self.textBubbleView)
        self.addSubview(self.photoBubbleView)
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        if self.isImageReply {
            self.setupPhotoBubbleView()
            return self.photoBubbleView.frame.size
        } else {
            self.setupTextBubbleView()
            return self.textBubbleView.frame.size
        }
    }

    // MARK: Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        if self.isImageReply {
            setupPhotoBubbleView()
            self.photoBubbleView.isHidden = false

            self.textBubbleView.isHidden = true
        } else {
            setupTextBubbleView()
            self.textBubbleView.isHidden = false

            self.photoBubbleView.isHidden = true
        }
    }

    private func updateViews() {
        if let viewModel = self.viewModel as? PhotoMessageViewModelProtocol {
            let replyPhotoViewModel = ReplyPhotoMessageViewModel(messageViewModel: self.viewModel)
            self.photoBubbleView.photoMessageViewModel = replyPhotoViewModel
        }

        if let viewModel = self.viewModel as? TextMessageViewModelProtocol {
            let replyTextViewModel = ReplyTextViewModel(messageViewModel: self.viewModel)
            self.textBubbleView.textMessageViewModel = replyTextViewModel
        }
    }

    private var isImageReply: Bool {
        self.viewModel.replyImage != nil
    }

    private func setupTextBubbleView() {
        let computedMaxBubbleWidth = self.frame.width

        textBubbleView.preferredMaxLayoutWidth = computedMaxBubbleWidth

        let size = textBubbleView.systemLayoutSizeFitting(CGSize(width: computedMaxBubbleWidth, height: CGFloat.greatestFiniteMagnitude))
        textBubbleView.frame.size.height = size.height
        textBubbleView.frame.size.width = size.width
    }

    private func setupPhotoBubbleView() {
        let computedMaxBubbleWidth = self.frame.width

        photoBubbleView.preferredMaxLayoutWidth = computedMaxBubbleWidth

        let size = photoBubbleView.systemLayoutSizeFitting(CGSize(width: computedMaxBubbleWidth, height: CGFloat.greatestFiniteMagnitude))
        photoBubbleView.frame.size.height = size.height
        photoBubbleView.frame.size.width = size.width
    }
}
