import Foundation
import UIKit

internal class ReplyViewPlaceholder {
    private static let emptyPhotoMessageModel = PhotoMessageModel(
        messageModel: MessageModel(
            uid: "",
            senderId: "",
            type: "photo",
            isIncoming: true,
            date: Date(),
            status: .success
        ),
        imageSize: CGSizeMake(50, 50),
        image: UIImage(systemName: "star")!
    )

    private static var emptyPhotoMessageViewModel: MessageViewModelProtocol {
        PhotoMessageViewModel(
            photoMessage: emptyPhotoMessageModel,
            messageViewModel: MessageViewModel(
                dateFormatter: MessageViewModelDefaultBuilder.dateFormatter,
                messageModel: emptyTextMessageModel,
                avatarImage: nil,
                decorationAttributes: BaseMessageDecorationAttributes()
            ),
            replyMessageViewModel: nil
        )
    }

    private static let emptyTextMessageModel = TextMessageModel(
        messageModel: MessageModel(
            uid: "",
            senderId: "",
            type: "text",
            isIncoming: true,
            date: Date(),
            status: .success
        ),
        text: ""
    )

    private static var emptyTextMessageViewModel: MessageViewModelProtocol {
        TextMessageViewModel(
            textMessage: emptyTextMessageModel,
            messageViewModel: MessageViewModel(
                dateFormatter: MessageViewModelDefaultBuilder.dateFormatter,
                messageModel: emptyTextMessageModel,
                avatarImage: nil,
                decorationAttributes: BaseMessageDecorationAttributes()
            )
        )
    }
    
    static var placeholderPhotoViewModel: PhotoMessageViewModel<PhotoMessageModel<MessageModel>> {
        PhotoMessageViewModel(
            photoMessage: emptyPhotoMessageModel,
            messageViewModel: emptyPhotoMessageViewModel,
            replyMessageViewModel: nil
        )
    }
    
    static var placeholderTextViewModel: TextMessageViewModel<TextMessageModel<MessageModel>> {
        TextMessageViewModel(
            textMessage: emptyTextMessageModel,
            messageViewModel: emptyTextMessageViewModel,
            replyMessageViewModel: nil
        )
    }
}
