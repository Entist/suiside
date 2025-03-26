
# SUI Side

**SUISIDE**는 SwiftUI에서 사용할 수 있는 커스텀 사이드 메뉴 컴포넌트입니다.

## 특징

- 드래그 제스처를 통한 메뉴 열기/닫기 기능
- 애니메이션 적용
- 커스터마이징 가능한 설정 (메뉴 너비, 애니메이션, 임계값 등)

## 설치 방법

Swift Package Manager를 사용하여 설치할 수 있습니다.

1. Xcode에서 프로젝트를 열고, **File > Swift Packages > Add Package Dependency...** 선택
2. GitHub URL 입력: `https://github.com/YourUsername/YourPackage.git`
3. 버전 또는 브랜치 선택

## 사용법

아래와 같이 사용 가능합니다:

```swift
import SUISide
import SwiftUI

struct ContentView: View {
    @State private var isMenuOpen = false

    var body: some View {
        NavigationView {
            Text("메인 콘텐츠")
                .sideMenu(isOpen: $isMenuOpen) {
                    VStack {
                        Text("사이드 메뉴 항목1")
                        Text("사이드 메뉴 항목2")
                    }
                }
                .navigationTitle("홈")
                .toolbar {
                    Button(action: {
                        isMenuOpen.toggle()
                    }) {
                        Image(systemName: "line.horizontal.3")
                    }
                }
        }
    }
}
