// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct SideMenu<Content: View>: View {
    @Binding var isOpen: Bool
    let menuWidth: CGFloat
    let content: () -> Content
    @State private var dragOffset: CGFloat = 0
    @State private var lastDragValue: CGFloat = 0
    private let animation: Animation
    private let edgeOffset: CGFloat
    private let dragThresholdPercentage: CGFloat
    
    /// SideMenu 초기화
    /// - Parameters:
    ///   - isOpen: 메뉴가 열려있는지 여부를 바인딩
    ///   - menuWidth: 메뉴의 너비 (기본값: 250)
    ///   - edgeOffset: 닫혔을 때 화면 가장자리로부터의 거리 (기본값: 0)
    ///   - animation: 메뉴 열림/닫힘에 사용할 애니메이션 (기본값: easeInOut)
    ///   - dragThresholdPercentage: 드래그 후 메뉴 상태를 전환할 임계값 백분율 (기본값: 0.3)
    ///   - content: 메뉴에 표시할 내용을 생성하는 클로저
    public init(
        isOpen: Binding<Bool>,
        menuWidth: CGFloat = 250,
        edgeOffset: CGFloat = 0,
        animation: Animation = .easeInOut(duration: 0.3),
        dragThresholdPercentage: CGFloat = 0.3,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isOpen = isOpen
        self.menuWidth = menuWidth
        self.edgeOffset = edgeOffset
        self.animation = animation
        self.dragThresholdPercentage = dragThresholdPercentage
        self.content = content
    }
    
    public var body: some View {
        ZStack(alignment: .leading) {
            // Main content area - covers the entire screen
            GeometryReader { geometry in
                Color.clear // This is just to ensure GeometryReader covers the whole space
                    .contentShape(Rectangle())
                    .edgesIgnoringSafeArea(.all)
                
                // Dimmed background when menu is open
                Color.black.opacity(isOpen ? 0.5 : 0)
                    .animation(animation, value: isOpen)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeMenu()
                    }
                
                // Side Menu content
                content()
                    .frame(width: menuWidth)
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.3), radius: 5)
                    .offset(x: calculateMenuOffset())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                handleDragChange(value)
                            }
                            .onEnded { value in
                                handleDragEnd(value, maxWidth: geometry.size.width)
                            }
                    )
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onChange(of: isOpen) { newValue in
            // isOpen 상태가 외부에서 변경되었을 때 자동으로 애니메이션 적용
            withAnimation(animation) {
                // 실제로는 아무 작업도 필요 없음, 단지 애니메이션 적용을 위한 목적
                dragOffset = 0 // 드래그 오프셋 리셋
            }
        }
    }
    
    private func calculateMenuOffset() -> CGFloat {
        if isOpen {
            return 0 + dragOffset // 메뉴가 열린 상태에서는 0부터 시작 (드래그 가능)
        } else {
            return -menuWidth + edgeOffset + dragOffset // 메뉴가 닫힌 상태에서는 -menuWidth부터 시작 (숨김 상태)
        }
    }
    
    private func handleDragChange(_ value: DragGesture.Value) {
        // 드래그 제스처에 기반한 이동
        let horizontalTranslation = value.translation.width
        
        if isOpen {
            // 메뉴가 열려있을 때는 왼쪽으로만 드래그 가능 (닫히는 방향)
            dragOffset = min(0, horizontalTranslation)
        } else {
            // 메뉴가 닫혀있을 때는 오른쪽으로만 드래그 가능 (열리는 방향)
            dragOffset = max(0, min(menuWidth, horizontalTranslation))
        }
        
        // 속도 계산을 위한 마지막 드래그 값 저장
        lastDragValue = horizontalTranslation
    }
    
    private func handleDragEnd(_ value: DragGesture.Value, maxWidth: CGFloat) {
        let horizontalTranslation = value.translation.width
        let dragThreshold = menuWidth * dragThresholdPercentage // 예: 30% 임계값
        
        withAnimation(animation) {
            if isOpen {
                // 메뉴가 열려있고, 왼쪽으로 충분히 드래그했으면 닫음
                if horizontalTranslation < -dragThreshold {
                    isOpen = false
                }
            } else {
                // 메뉴가 닫혀있고, 오른쪽으로 충분히 드래그했으면 열음
                if horizontalTranslation > dragThreshold {
                    isOpen = true
                }
            }
            
            // 드래그 오프셋 리셋
            dragOffset = 0
        }
    }
    
    /// 메뉴를 닫는 함수
    private func closeMenu() {
        withAnimation(animation) {
            isOpen = false
            dragOffset = 0
        }
    }
    
    /// 메뉴를 여는 함수
    public func openMenu() {
        withAnimation(animation) {
            isOpen = true
            dragOffset = 0
        }
    }
    
    /// 메뉴 상태를 토글하는 함수
    public func toggleMenu() {
        withAnimation(animation) {
            isOpen.toggle()
            dragOffset = 0
        }
    }
}

// MARK: - View 확장 메서드
public extension View {
    /// 현재 뷰에 사이드 메뉴를 추가하는 메서드
    /// - Parameters:
    ///   - isOpen: 메뉴가 열려있는지 여부를 바인딩
    ///   - menuWidth: 메뉴의 너비 (기본값: 250)
    ///   - edgeOffset: 닫혔을 때 화면 가장자리로부터의 거리 (기본값: 0)
    ///   - animation: 메뉴 열림/닫힘에 사용할 애니메이션 (기본값: easeInOut)
    ///   - dragThresholdPercentage: 드래그 후 메뉴 상태를 전환할 임계값 백분율 (기본값: 0.3)
    ///   - content: 메뉴에 표시할 내용을 생성하는 클로저
    /// - Returns: 사이드 메뉴가 추가된 뷰
    func sideMenu<Content: View>(
        isOpen: Binding<Bool>,
        menuWidth: CGFloat = 250,
        edgeOffset: CGFloat = 0,
        animation: Animation = .easeInOut(duration: 0.3),
        dragThresholdPercentage: CGFloat = 0.3,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        ZStack {
            self
            SideMenu(
                isOpen: isOpen,
                menuWidth: menuWidth,
                edgeOffset: edgeOffset,
                animation: animation,
                dragThresholdPercentage: dragThresholdPercentage,
                content: content
            )
        }
    }
}
