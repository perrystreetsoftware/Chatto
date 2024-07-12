import Foundation

public final class ReplyView: UIView, MaximumLayoutWidthSpecificable {
    private static let horizontalMargin: CGFloat = 16
    private static let indicatorHorizontalMargin: CGFloat = 4

    public var viewModel: MessageViewModelProtocol! {
        didSet {
            self.updateViews()
        }
    }
    
    public var baseStyle: BaseMessageCollectionViewCellStyleProtocol! {
        didSet {
            self.updateViews()
        }
    }
    
    public var isReplyFromIncomingMessage: Bool! {
        didSet {
            self.updateViews()
        }
    }
    
    public lazy var photoBubbleView: PhotoBubbleView = {
        let bubbleView = PhotoBubbleView()
        bubbleView.photoMessageViewModel = ReplyViewPlaceholder.placeholderPhotoViewModel
        bubbleView.photoMessageStyle = ReplyPhotoStyle()
        return bubbleView
    }()
    
    public lazy var textBubbleView: TextBubbleView = {
        let bubbleView = TextBubbleView()
        bubbleView.layoutCache = NSCache<AnyObject, AnyObject>()
        bubbleView.textMessageViewModel = ReplyViewPlaceholder.placeholderTextViewModel
        bubbleView.maxNumberOfLines = 1
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
    
    private let indicator = UIImageView()

    public var preferredMaxLayoutWidth: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        self.addSubview(self.photoBubbleView)
        self.addSubview(self.textBubbleView)
        self.addSubview(self.indicator)
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        if self.isImageReply {
            self.setupPhotoBubbleView()
            return self.photoBubbleView.sizeThatFits(size)
        } else if self.isTextReply {
            self.setupTextBubbleView()
            return self.textBubbleView.sizeThatFits(size)
        } else {
            return .zero
        }
    }

    // MARK: Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.indicator.isHidden = false
        
        var currentX: CGFloat = 0
        indicator.center.y = frame.height / 2
        
        if self.isImageReply {
            setupPhotoBubbleView()
            self.photoBubbleView.isHidden = false
            self.textBubbleView.isHidden = true
            
            self.photoBubbleView.frame.origin.x = self.indicator.frame.width + ReplyView.indicatorHorizontalMargin
        } else if self.isTextReply {
            setupTextBubbleView()
            self.textBubbleView.isHidden = false
            self.photoBubbleView.isHidden = true
            
            self.textBubbleView.frame.origin.x = self.indicator.frame.width + ReplyView.indicatorHorizontalMargin
        } else {
            self.textBubbleView.isHidden = true
            self.photoBubbleView.isHidden = true
            self.indicator.isHidden = true
        }
        
        if isReplyFromIncomingMessage {
            indicator.frame.origin.x = currentX
            currentX += indicator.frame.width + ReplyView.indicatorHorizontalMargin
            textBubbleView.frame.origin.x = currentX
            photoBubbleView.frame.origin.x = currentX
        } else {
            let bubbleView: UIView = textBubbleView.isHidden ? photoBubbleView : textBubbleView
            currentX = bubbleView.frame.maxX - (indicator.frame.width + ReplyView.horizontalMargin)
            currentX -= indicator.frame.width
            indicator.frame.origin.x = currentX
            
            currentX -= bubbleView.frame.width
            bubbleView.frame.origin.x = currentX
        }
    }
    
    public func setTextBubbleViewStyle(style: TextBubbleViewStyleProtocol) {
        textBubbleView.style = style
    }

    private func updateViews() {
        if let viewModel = self.viewModel as? PhotoMessageViewModelProtocol {
            photoBubbleView.photoMessageViewModel = viewModel
        }

        if let viewModel = self.viewModel as? TextMessageViewModelProtocol {
            textBubbleView.textMessageViewModel = viewModel
        }
        
        if let indicatorStyle = baseStyle?.replyIndicatorStyle {
            rotateIndicatorYAxis()
            indicator.image = indicatorStyle.image
            indicator.bounds.size = indicatorStyle.size
        }
    }

    private var isImageReply: Bool {
        viewModel is PhotoMessageViewModelProtocol
    }

    private var isTextReply: Bool {
        viewModel is TextMessageViewModelProtocol
    }

    private func setupTextBubbleView() {
        textBubbleView.preferredMaxLayoutWidth = preferredMaxLayoutWidth

        let size = textBubbleView.systemLayoutSizeFitting(CGSize(width: preferredMaxLayoutWidth, height: CGFloat.greatestFiniteMagnitude))
        
        textBubbleView.frame.size.height = size.height
        textBubbleView.frame.size.width = size.width
    }

    private func setupPhotoBubbleView() {
        photoBubbleView.preferredMaxLayoutWidth = preferredMaxLayoutWidth

        let size = photoBubbleView.systemLayoutSizeFitting(CGSize(width: preferredMaxLayoutWidth, height: CGFloat.greatestFiniteMagnitude))
        
        photoBubbleView.frame.size.height = size.height
        photoBubbleView.frame.size.width = size.width
    }
    
    private func rotateIndicatorYAxis() {
        if isReplyFromIncomingMessage {
            let transform = CATransform3DRotate(CATransform3DIdentity, .pi, 0, 1, 0)
            indicator.layer.transform = transform
        } else {
            indicator.layer.transform = CATransform3DIdentity
        }
    }
}
