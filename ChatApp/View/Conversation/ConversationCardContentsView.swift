//
//  ConversationCardContentsView.swift
//  ChatApp
//
//  Created by wyn on 2023/4/5.
//

import SwiftUI
import RealmSwift

struct ConversationCardContentsView: View {
    @ObservedResults(Chatster.self) var chatsters

    let conversation: Conversation

    private enum Dimensions {
        static let mugWidth: CGFloat = 110
        static let cornerRadius: CGFloat = 5
        static let lineWidth: CGFloat = 1
        static let padding: CGFloat = 5
    }

    var chatMembers: [Chatster] {
        var chatsterList = [Chatster]()
        for member in conversation.members {
            chatsterList.append(contentsOf: chatsters.filter("userName = %@", member.userName))
        }
        return chatsterList
    }

    private var caption: String {
        return conversation.unreadCount == 0 ?
        "" : "\(conversation.unreadCount) new \(conversation.unreadCount == 1 ? "message" : "messages")"
    }

    var body: some View {
        HStack {
            MugShotGridView(members: chatMembers)
                .frame(width: Dimensions.mugWidth)
                .padding(.trailing)
            VStack(alignment: .leading) {
                Text(conversation.displayName)
                    .fontWeight(conversation.unreadCount > 0 ? .bold : .regular)
                CaptionLabel(title: caption)
            }
            Spacer()
        }
        .padding(Dimensions.padding)
        .overlay(RoundedRectangle(cornerRadius: Dimensions.cornerRadius)
            .stroke(Color.gray, lineWidth: Dimensions.lineWidth))
    }
}

struct ConversationCardContentsView_Previews: PreviewProvider {
    static var previews: some View {
        Realm.bootstrap()

        return ForEach(Conversation.samples) { conversation in
            ConversationCardContentsView(conversation: conversation)
        }
        .previewLayout(.sizeThatFits)
    }
}
