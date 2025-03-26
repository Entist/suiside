
# SUI Side

**SUISIDE**는 SwiftUI에서 사용할 수 있는 커스텀 사이드 메뉴 컴포넌트입니다.

## 특징

- 드래그 제스처를 통한 메뉴 열기/닫기 기능
- 애니메이션 적용
- 커스터마이징 가능한 설정 (메뉴 너비, 애니메이션, 임계값 등)

## 설치 방법

Swift Package Manager를 사용하여 설치할 수 있습니다.

1. Xcode에서 프로젝트를 열고, **File > Swift Packages > Add Package Dependency...** 선택
2. GitHub URL 입력: `[https://github.com/Entist/suiside.git](https://github.com/Entist/suiside)`
3. 버전 또는 브랜치 선택

## 사용법

아래와 같이 사용 가능합니다:

```swift
struct ContentView: View {
    @State private var isMenuOpen: Bool = false
    
    var body: some View {
        ZStack {
            // 메인 콘텐츠 영역 (NavigationView 사용)
            NavigationView {
                VStack {
                    Text("메인 콘텐츠")
                        .font(.largeTitle)
                        .padding()
                    Spacer()
                }
                .navigationTitle("홈")
                .toolbar {
                    // 햄버거 버튼: 사이드 메뉴 토글
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                isMenuOpen.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .imageScale(.large)
                        }
                    }
                }
            }
            .zIndex(0)
            
            // 사이드 메뉴 열림 시 dim 배경 추가
            if isMenuOpen {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isMenuOpen = false
                        }
                    }
                    .zIndex(1)
            }
            
            // SideMenu 컴포넌트를 활용한 사이드 메뉴 구현
            SideMenu(isOpen: $isMenuOpen, menuWidth: 250) {
                VStack(alignment: .leading, spacing: 20) {
                    Button("홈") {
                        withAnimation { isMenuOpen = false }
                    }
                    Button("프로필") {
                        withAnimation { isMenuOpen = false }
                    }
                    Button("설정") {
                        withAnimation { isMenuOpen = false }
                    }
                    Spacer()
                }
                .padding(.top, 60)
                .padding(.horizontal, 20)
            }
            .zIndex(2)
        }
    }
}
```

