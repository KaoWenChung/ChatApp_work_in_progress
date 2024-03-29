//
//  AvatarButton.swift
//  ChatApp
//
//  Created by wyn on 2023/4/5.
//

import SwiftUI

struct AvatarButton: View {
    let photo: Photo
    let action: () -> Void

    private enum Dimensions {
        static let frameWidth: CGFloat = 40
        static let frameHeight: CGFloat = 30
        static let opacity = 0.9
    }

    var body: some View {
        ZStack {
            Button(action: action) {
                AvatarThumbNailView(photo: photo)
            }
            Image(systemName: "camera.fill")
                .resizable()
                .frame(width: Dimensions.frameWidth, height: Dimensions.frameHeight)
                .foregroundColor(.gray)
                .opacity(Dimensions.opacity)
        }
    }
}

struct AvatarButton_Previews: PreviewProvider {
    static var previews: some View {
        AvatarButton(photo: .sample, action: {})
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
