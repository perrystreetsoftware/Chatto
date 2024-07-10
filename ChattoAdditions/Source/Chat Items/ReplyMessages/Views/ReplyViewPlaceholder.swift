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
