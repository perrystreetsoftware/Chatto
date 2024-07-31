import Foundation
import Chatto

public final class ReplyPhotoStyle: PhotoMessageCollectionViewCellDefaultStyle {
    private let resizePercentage: Double
    
    public init(resizePercentage: Double = 0.5) {
        self.resizePercentage = resizePercentage
    }
    
    override public func bubbleSize(viewModel: any PhotoMessageViewModelProtocol) -> CGSize {
        let defaultSize = super.bubbleSize(viewModel: viewModel)
        let width = defaultSize.width * resizePercentage
        let height = defaultSize.height * resizePercentage
        return CGSize(width: width, height: height)
    }
}
