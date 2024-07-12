import Foundation
import ChattoAdditions

final class DemoReplyMessageViewModelBuilder: ReplyMessageViewModelBuilder {
    override func createViewModel(_ model: MessageModelProtocol?) -> MessageViewModelProtocol? {
        guard let model = model else { return nil }
        
        let viewModel = messageViewModelBuilder.createMessageViewModel(model)

        return switch model.type {
        case _ where textItemTypes.contains(model.type):
            DemoTextMessageViewModel(
                textMessage: model as! DemoTextMessageModel,
                messageViewModel: viewModel,
                replyMessageViewModel: nil
            )
        case _ where photoItemTypes.contains(model.type):
            DemoPhotoMessageViewModel(
                photoMessage: model as! DemoPhotoMessageModel,
                messageViewModel: viewModel,
                replyMessageViewModel: nil
            )
        default:
            nil
        }
    }
}
