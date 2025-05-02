import SwiftUI

/// Configuration options for the SideMenu
public struct SideMenuConfiguration {
    let menuWidth: CGFloat
    let edgeOffset: CGFloat
    let animation: Animation
    let dragThresholdPercentage: CGFloat
    let backgroundColor: Color
    let shadowRadius: CGFloat
    let edgeSwipeWidth: CGFloat
    
    public init(
        menuWidth: CGFloat = 250,
        edgeOffset: CGFloat = 0,
        animation: Animation = .easeInOut(duration: 0.3),
        dragThresholdPercentage: CGFloat = 0.3,
        backgroundColor: Color = Color(UIColor.systemBackground),
        shadowRadius: CGFloat = 5,
        edgeSwipeWidth: CGFloat = 20
    ) {
        self.menuWidth = menuWidth
        self.edgeOffset = edgeOffset
        self.animation = animation
        self.dragThresholdPercentage = dragThresholdPercentage
        self.backgroundColor = backgroundColor
        self.shadowRadius = shadowRadius
        self.edgeSwipeWidth = edgeSwipeWidth
    }
}

/// Manages drag gesture state and logic for the SideMenu
struct MenuDragController {
    private(set) var currentDragTranslation: CGFloat = 0
    private var previousDragTranslation: CGFloat = 0
    
    /// Processes drag gesture change
    /// - Parameters:
    ///   - value: Current drag gesture value
    ///   - isOpen: Current open state of the menu
    ///   - menuWidth: Width of the menu
    mutating func processDragMovement(_ value: DragGesture.Value, isOpen: Bool, menuWidth: CGFloat) {
        let horizontalTranslation = value.translation.width
        
        if isOpen {
            // When menu is open, only allow dragging left (closing direction)
            currentDragTranslation = min(0, horizontalTranslation)
        } else {
            // When menu is closed, only allow dragging right (opening direction)
            currentDragTranslation = max(0, min(menuWidth, horizontalTranslation))
        }
        
        // Store for velocity calculations
        previousDragTranslation = horizontalTranslation
    }
    
    /// Determines if menu state should change based on drag end
    /// - Parameters:
    ///   - value: Final drag gesture value
    ///   - isOpen: Current open state of the menu
    ///   - threshold: Threshold for triggering state change
    /// - Returns: Whether the menu state should toggle
    func shouldToggleMenuState(_ value: DragGesture.Value, isOpen: Bool, threshold: CGFloat) -> Bool {
        let horizontalTranslation = value.translation.width
        
        if isOpen {
            // If menu is open and dragged left beyond threshold, close it
            return horizontalTranslation < -threshold
        } else {
            // If menu is open and dragged right beyond threshold, open it
            return horizontalTranslation > threshold
        }
    }
    
    /// Resets drag state
    mutating func resetDrag() {
        currentDragTranslation = 0
        previousDragTranslation = 0
    }
}

/// A side menu component that slides in from the left edge of the screen
@available(iOS 14.0, macOS 11.0, *)
public struct SideMenu<Content: View>: View {
    @Binding var isOpen: Bool
    private let config: SideMenuConfiguration
    private let content: () -> Content
    @State private var dragController = MenuDragController()
    
    /// Initializes a new side menu
    /// - Parameters:
    ///   - isOpen: Binding to control the open/closed state
    ///   - configuration: Configuration options for the menu (optional)
    ///   - content: Content to display in the menu
    public init(
        isOpen: Binding<Bool>,
        configuration: SideMenuConfiguration = SideMenuConfiguration(),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isOpen = isOpen
        self.config = configuration
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Edge detection for swipe gestures
                edgeDetectionArea(geometry: geometry)
                
                // Dimmed overlay when menu is open
                overlayView()
                
                // Side menu content
                menuContent(geometry: geometry)
            }
            .ignoresSafeArea()
        }
        .onChange(of: isOpen) {
            withAnimation(config.animation) {
                dragController.resetDrag()
            }
        }
    }
    
    /// Creates the edge detection area for swipe gestures
    private func edgeDetectionArea(geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            // Left edge area that enables swipe to open
            Color.clear
                .frame(width: config.edgeSwipeWidth)
                .contentShape(Rectangle())
                .allowsHitTesting(!isOpen) // Only active when menu is closed
                .gesture(
                    DragGesture(minimumDistance: 5)
                        .onChanged { value in
                            if value.translation.width > 0 { // Only detect right swipes
                                dragController.processDragMovement(
                                    value,
                                    isOpen: isOpen,
                                    menuWidth: config.menuWidth
                                )
                            }
                        }
                        .onEnded { value in
                            handleDragEnd(value, geometry: geometry)
                        }
                )
            
            // Rest of screen - passes touches through
            Color.clear
                .frame(width: geometry.size.width - config.edgeSwipeWidth)
                .allowsHitTesting(false)
        }
    }
    
    /// Creates the overlay view that dims the background when menu is open
    private func overlayView() -> some View {
        Group {
            if isOpen {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .animation(config.animation, value: isOpen)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        closeMenu()
                    }
            }
        }
    }
    
    /// Creates the menu content
    private func menuContent(geometry: GeometryProxy) -> some View {
        content()
            .frame(width: config.menuWidth)
            .background(config.backgroundColor)
            .shadow(color: Color.black.opacity(0.3), radius: config.shadowRadius)
            .offset(x: computeMenuPosition())
            .animation(config.animation, value: isOpen)
            .animation(config.animation, value: dragController.currentDragTranslation)
            .accessibilityLabel("Side Menu")
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragController.processDragMovement(
                            value,
                            isOpen: isOpen,
                            menuWidth: config.menuWidth
                        )
                    }
                    .onEnded { value in
                        handleDragEnd(value, geometry: geometry)
                    }
            )
    }
    
    /// Calculates the current horizontal position of the menu
    private func computeMenuPosition() -> CGFloat {
        if isOpen {
            return 0 + dragController.currentDragTranslation
        } else {
            return -config.menuWidth + config.edgeOffset + dragController.currentDragTranslation
        }
    }
    
    /// Handles drag gesture end
    private func handleDragEnd(_ value: DragGesture.Value, geometry: GeometryProxy) {
        let dragThreshold = config.menuWidth * config.dragThresholdPercentage
        
        withAnimation(config.animation) {
            if dragController.shouldToggleMenuState(value, isOpen: isOpen, threshold: dragThreshold) {
                isOpen.toggle()
            }
            
            dragController.resetDrag()
        }
    }
    
    /// Closes the menu with animation
    private func closeMenu() {
        withAnimation(config.animation) {
            isOpen = false
            dragController.resetDrag()
        }
    }
    
    /// Opens the menu with animation
    public func openMenu() {
        withAnimation(config.animation) {
            isOpen = true
            dragController.resetDrag()
        }
    }
    
    /// Toggles the menu state with animation
    public func toggleMenu() {
        withAnimation(config.animation) {
            isOpen.toggle()
            dragController.resetDrag()
        }
    }
}

// MARK: - View Extension
public extension View {
    /// Adds a side menu to the current view
    /// - Parameters:
    ///   - isOpen: Binding to control the open/closed state
    ///   - configuration: Configuration options for the menu (optional)
    ///   - content: Content to display in the menu
    /// - Returns: View with side menu attached
    func sideMenu<Content: View>(
        isOpen: Binding<Bool>,
        configuration: SideMenuConfiguration = SideMenuConfiguration(),
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.overlay(
            SideMenu(
                isOpen: isOpen,
                configuration: configuration,
                content: content
            ),
            alignment: .center
        )
    }
}