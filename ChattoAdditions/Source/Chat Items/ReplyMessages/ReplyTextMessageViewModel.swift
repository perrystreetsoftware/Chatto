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
import UIKit
import Chatto

public final class ReplyTextMessageViewModel<TextMessageModelT: TextMessageModelProtocol>: TextMessageViewModelProtocol {
    public func copy() -> any MessageViewModelProtocol {
        let theCopy = messageViewModel.copy()
        return ReplyTextMessageViewModel(textMessage: textMessage, messageViewModel: theCopy)
    }

    public var reply: MessageViewModelProtocol? = nil

    public var text: String {
        return self.textMessage.text
    }
    
    public let textMessage: TextMessageModelT
    public let messageViewModel: MessageViewModelProtocol
    
    public let cellAccessibilityIdentifier = "chatto.message.reply.text.cell"
    public let bubbleAccessibilityIdentifier = "chatto.message.reply.text.bubble"

    public init(
        textMessage: TextMessageModelT,
        messageViewModel: MessageViewModelProtocol
    ) {
        self.textMessage = textMessage
        self.messageViewModel = messageViewModel
    }

    public func willBeShown() {
        // Need to declare empty. Otherwise subclass code won't execute (as of Xcode 7.2)
    }

    public func wasHidden() {
        // Need to declare empty. Otherwise subclass code won't execute (as of Xcode 7.2)
    }
}
