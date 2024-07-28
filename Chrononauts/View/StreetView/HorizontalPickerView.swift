//
//  HorizontalView.swift
//  Chrononauts
//
//  Created by FredyCamas on 7/26/24.
//

import SwiftUI
struct HorizontalPickerView: View {
    var images: [PanoImages]
    var onImageSelected: (PanoImages?) -> Void
    
    @State private var selectedIndex: Int?
    @State private var scrollViewProxy: ScrollViewProxy?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                HStack(spacing: 15) {
                    ForEach(images.indices, id: \.self) { index in
                        VStack {
                            Image(uiImage: UIImage(named: "\(images[index].name)")!)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(selectedIndex == index ? Color.green : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    if selectedIndex == index {
//                                        selectedIndex = nil
//                                        onImageSelected(nil) // Notify that no image is selected
                                    } else {
                                        selectedIndex = index
                                        onImageSelected(images[index])
                                    }
                                    scrollToSelectedIndex(proxy: proxy)
                                }
                                .id(index)
                            
                            Text(images[index].year)
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .onAppear {
                    scrollViewProxy = proxy
                    scrollToSelectedIndex(proxy: proxy)
                    selectedIndex = 0
                }
                .onChange(of: selectedIndex) { _ in
                    if let proxy = scrollViewProxy {
                        scrollToSelectedIndex(proxy: proxy)
                    }
                }
            }
        }
        .frame(height: 140) // Increased height to accommodate year text
    }
    
    private func scrollToSelectedIndex(proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            if let index = selectedIndex {
                proxy.scrollTo(index, anchor: .center)
            }
        }
    }
}
