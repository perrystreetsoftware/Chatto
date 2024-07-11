import Foundation
import Chatto

public final class ReplyPhotoStyle: PhotoMessageCollectionViewCellDefaultStyle {
    override public func bubbleSize(viewModel: any PhotoMessageViewModelProtocol) -> CGSize {
        let width = viewModel.imageSize.width * 0.5
        let height = viewModel.imageSize.height * 0.5

        return CGSize(width: width, height: height)
    }
}
