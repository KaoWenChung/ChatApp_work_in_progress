//
//  ConversationListView.swift
//  ChatApp
//
//  Created by wyn on 2023/4/4.
//

import SwiftUI
import RealmSwift

struct ConversationListView: View {
    @EnvironmentObject var state: AppState
    @ObservedRealmObject var user: User

    var isPreview = false

    @State private var conversation: Conversation?
    @State private var showConversation = false
    @State private var showingAddChat = false

    private let sortDescriptors = [
        SortDescriptor(keyPath: "unreadCount", ascending: false),
        SortDescriptor(keyPath: "displayName", ascending: true)
    ]

    var body: some View {
        ZStack {
            VStack {
                if let conversations = user.conversations.sorted(by: sortDescriptors) {
                    List {
                        ForEach(conversations) { conversation in
                            Button(action: {
                                self.conversation = conversation
                                showConversation.toggle()
                            }, label: {
                                ConversationCardView(conversation: conversation, isPreview: isPreview)
                            })
                        }
                    }
                    Button(action: { showingAddChat.toggle() },
                           label: {
                        Text("New Chat Room")
                    })
                    .disabled(showingAddChat)
                }
                Spacer()
                if isPreview {
                    NavigationLink(
                        destination: ChatRoomView(user: user, conversation: conversation),
                        isActive: $showConversation) { EmptyView() }
                } else {
                    if let realmUser = app.currentUser {
                        NavigationLink(destination: ChatRoomView(user: user,
                                                                 conversation: conversation)
                            .environment(\.realmConfiguration,
                                          realmUser.configuration(partitionValue: "user=\(user.id)")),
                                       isActive: $showConversation) { EmptyView()}
                    }
                }
            }
        }
        .onAppear {
            $user.presenceState.wrappedValue = .onLine
        }
        .sheet(isPresented: $showingAddChat) {
            NewConversationView(user: user)
                .environmentObject(state)
                .environment(\.realmConfiguration,
                              app.currentUser!.configuration(partitionValue: "all-users=all-the-users"))
        }
    }
}

struct ConversationListView_Previews: PreviewProvider {
    static var previews: some View {
        Realm.bootstrap()

        return ConversationListView(user: .sample)
    }
}
