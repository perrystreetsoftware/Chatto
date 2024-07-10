import Foundation
import Chatto

public final class ReplyMessageViewModelBuilder {
    private let messageViewModelBuilder = MessageViewModelDefaultBuilder()
    
    private let textItemTypes: [ChatItemType]
    private let photoItemTypes: [ChatItemType]
    
    public init(textItemTypes: [ChatItemType], photoItemTypes: [ChatItemType]) {
        self.textItemTypes = textItemTypes
        self.photoItemTypes = photoItemTypes
    }
    
    public func createViewModel(_ model: MessageModelProtocol?) -> MessageViewModelProtocol? {
        guard let model = model else { return nil }
        
        let viewModel = messageViewModelBuilder.createMessageViewModel(model)

        return switch model.type {
        case _ where textItemTypes.contains(model.type):
            TextMessageViewModel(
                textMessage: model as! TextMessageModel<MessageModel>,
                messageViewModel: viewModel,
                replyMessageViewModel: nil
            )
        case _ where photoItemTypes.contains(model.type):
            PhotoMessageViewModel(
                photoMessage: model as! PhotoMessageModel<MessageModel>,
                messageViewModel: viewModel,
                replyMessageViewModel: nil
            )
        default:
            nil
        }
    }
}
