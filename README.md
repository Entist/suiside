# SwiftUI 사이드 메뉴 (SwiftUI Side Menu)

안녕하세요! 👋

이 저장소는 SwiftUI를 사용하여 구현된 간단하면서도 유연하게 사용자 정의 가능한 왼쪽 사이드 메뉴 컴포넌트를 제공합니다. 슬라이드 애니메이션, 드래그 제스처, 탭하여 닫기 등 일반적인 사이드 메뉴 기능을 쉽게 앱에 통합할 수 있도록 설계되었습니다.

## ✨ 주요 기능

* **슬라이드 인/아웃:** 부드러운 애니메이션과 함께 화면 왼쪽에서 메뉴가 나타나고 사라집니다.
* **드래그 제스처:** 사용자가 메뉴를 직접 드래그하여 열고 닫을 수 있습니다.
* **탭하여 닫기:** 메뉴가 열려 있을 때 메뉴 외부의 어두운 영역을 탭하면 메뉴가 닫힙니다.
* **사용자 정의:** 메뉴 너비, 배경색, 애니메이션, 그림자 등 다양한 속성을 쉽게 설정할 수 있습니다. (`SideMenuConfiguration`)
* **프로그래밍 방식 제어:** `@Binding` 변수를 통해 메뉴의 열림/닫힘 상태를 제어하고, `openMenu()`, `closeMenu()`, `toggleMenu()` 함수를 호출하여 메뉴 상태를 변경할 수 있습니다.
* **SwiftUI 통합:** `View` 확장을 통해 어떤 SwiftUI 뷰에도 `.sideMenu(...)` 수정자를 사용하여 간단하게 적용할 수 있습니다.
* **상태 관리:** 드래그 상태를 내부적으로 관리하여 복잡성을 줄였습니다. (`MenuDragController`)

## ✅ 요구 사항

* iOS 14.0 이상
* macOS 11.0 이상
* Swift 5.3 이상
* SwiftUI 프레임워크

## 🚀 설치

Swift Package Manager를 사용하여 설치할 수 있습니다.

1. Xcode에서 프로젝트를 열고, **File > Swift Packages > Add Package Dependency...** 선택
2. GitHub URL 입력: `[https://github.com/Entist/suiside.git](https://github.com/Entist/suiside)`
3. 버전 또는 브랜치 선택

## 🛠️ 사용 방법

### 1. 기본 사용법

가장 기본적인 방법은 `@State` 변수를 사용하여 메뉴의 열림/닫힘 상태를 관리하고, `.sideMenu` 뷰 수정자를 사용하여 메뉴를 뷰 계층 구조에 추가하는 것입니다.

```swift
import SwiftUI

struct ContentView: View {
    @State private var isMenuOpen = false // 메뉴 상태를 관리할 @State 변수

    var body: some View {
        NavigationView { // 또는 다른 루트 뷰
            VStack {
                Text("메인 컨텐츠 영역")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.2))
            }
            .navigationTitle("Side Menu 예제")
            .navigationBarItems(leading: Button {
                // 버튼을 눌러 메뉴 상태 토글
                withAnimation {
                    isMenuOpen.toggle()
                }
            } label: {
                Image(systemName: "line.3.horizontal")
            })
        }
        // .sideMenu 수정자를 사용하여 메뉴 추가
        .sideMenu(isOpen: $isMenuOpen) {
            // 여기에 메뉴 컨텐츠 뷰를 정의합니다.
            MenuView() // 예시 메뉴 뷰
        }
    }
}

// 사이드 메뉴에 표시될 컨텐츠 뷰 (예시)
struct MenuView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("메뉴 항목 1")
            Text("메뉴 항목 2")
            Text("설정")
            Spacer() // 나머지 공간 채우기
        }
        .padding(.top, 50) // 상단 여백
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 정렬 및 너비 최대화
        .background(Color(UIColor.secondarySystemBackground)) // 메뉴 배경색 (기본값과 다르게 설정 가능)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```

### 2. 사용자 정의 설정 (`SideMenuConfiguration`)

`SideMenuConfiguration` 객체를 생성하여 메뉴의 모양과 동작을 상세하게 설정할 수 있습니다.

```swift
import SwiftUI

struct ContentView: View {
    @State private var isMenuOpen = false

    // 사용자 정의 설정 생성
    let menuConfig = SideMenuConfiguration(
        menuWidth: 300, // 메뉴 너비 변경
        edgeOffset: 20, // 닫혔을 때 살짝 보이도록 설정
        animation: .spring(response: 0.4, dampingFraction: 0.8), // 애니메이션 변경
        dragThresholdPercentage: 0.25, // 드래그 민감도 조절 (25% 이상 드래그 시 상태 변경)
        backgroundColor: Color.blue.opacity(0.9), // 메뉴 배경색 변경
        shadowRadius: 10 // 그림자 반경 변경
    )

    var body: some View {
        NavigationView {
            VStack {
                Text("메인 컨텐츠 영역 (사용자 정의)")
            }
            .navigationTitle("Side Menu 예제")
            .navigationBarItems(leading: Button {
                withAnimation(menuConfig.animation) { // 설정된 애니메이션 사용
                    isMenuOpen.toggle()
                }
            } label: {
                Image(systemName: "line.3.horizontal")
            })
        }
        // .sideMenu 수정자에 configuration 전달
        .sideMenu(isOpen: $isMenuOpen, configuration: menuConfig) {
            MenuView() // 동일한 메뉴 뷰 사용
                .background(Color.clear) // MenuView 자체 배경을 투명하게 하여 configuration의 배경색이 보이도록 함
        }
    }
}

// MenuView는 이전과 동일하게 사용 가능
struct MenuView: View {
     var body: some View {
         VStack(alignment: .leading, spacing: 20) {
             Text("사용자 정의 메뉴 1").foregroundColor(.white) // 텍스트 색상 변경
             Text("사용자 정의 메뉴 2").foregroundColor(.white)
             Text("설정").foregroundColor(.white)
             Spacer()
         }
         .padding(.top, 50)
         .padding(.horizontal)
         .frame(maxWidth: .infinity, alignment: .leading)
         // .background(...) 를 여기서 설정하면 configuration의 backgroundColor를 덮어쓰므로 주의
     }
}
```

### 3. 프로그래밍 방식 제어

`SideMenu` 인스턴스에 직접 접근할 수는 없지만, `isOpen` 바인딩을 변경하거나, 만약 `SideMenu`를 직접 관리하는 구조라면 (예: `View` 확장 대신 직접 `ZStack` 내부에 `SideMenu`를 배치), 해당 인스턴스의 `openMenu()`, `closeMenu()`, `toggleMenu()` 메소드를 사용할 수 있습니다. 하지만 일반적으로는 `@Binding` 변수를 조작하는 것이 SwiftUI의 방식에 더 부합합니다.

```swift
// ... ContentView 내부 ...
Button("메뉴 열기") {
    // openMenu() 와 동일한 효과
    withAnimation(menuConfig.animation) { // 애니메이션과 함께
        isMenuOpen = true
    }
}

Button("메뉴 닫기") {
    // closeMenu() 와 동일한 효과
    withAnimation(menuConfig.animation) { // 애니메이션과 함께
        isMenuOpen = false
    }
}

Button("메뉴 토글") {
    // toggleMenu() 와 동일한 효과
    withAnimation(menuConfig.animation) { // 애니메이션과 함께
        isMenuOpen.toggle()
    }
}
```

## ⚙️ 설정 옵션 (`SideMenuConfiguration`)

| 속성                    | 타입        | 설명                                                                 | 기본값                                  |
| :---------------------- | :---------- | :------------------------------------------------------------------- | :-------------------------------------- |
| `menuWidth`             | `CGFloat`   | 사이드 메뉴의 너비입니다.                                            | `250`                                   |
| `edgeOffset`            | `CGFloat`   | 메뉴가 닫혔을 때 화면 가장자리에서 얼마나 보일지 설정합니다. (0이면 완전히 숨김) | `0`                                     |
| `animation`             | `Animation` | 메뉴가 열리고 닫힐 때 사용될 애니메이션입니다.                       | `.easeInOut(duration: 0.3)`           |
| `dragThresholdPercentage` | `CGFloat`   | 메뉴 너비 대비 드래그 거리가 이 비율을 넘어야 메뉴 상태가 변경됩니다. (0.0 ~ 1.0) | `0.3` (30%)                           |
| `backgroundColor`       | `Color`     | 사이드 메뉴의 배경색입니다.                                          | `Color(UIColor.systemBackground)` |
| `shadowRadius`          | `CGFloat`   | 메뉴 오른쪽에 적용될 그림자의 반경입니다.                            | `5`                                     |

## 📐 코드 구조 분석

* **`SideMenuConfiguration` (Struct):**
    * 사이드 메뉴의 외형과 동작 방식을 정의하는 설정 값들을 모아놓은 구조체입니다.
    * 각 속성에 기본값이 설정되어 있어, 별도의 설정 없이도 바로 사용할 수 있습니다.
* **`MenuDragController` (Struct):**
    * 사용자의 드래그 제스처 상태(`currentDragTranslation`)를 관리하고, 드래그 변화(`processDragMovement`) 및 종료 시(`shouldToggleMenuState`)의 로직을 처리합니다.
    * 메뉴가 열려있을 때와 닫혀있을 때의 드래그 방향을 제한하는 로직이 포함되어 있습니다.
    * `resetDrag()` 함수는 드래그 상태를 초기화합니다.
* **`SideMenu<Content: View>` (Struct):**
    * 실제 사이드 메뉴 UI를 구성하는 메인 SwiftUI `View`입니다.
    * `@Binding var isOpen`: 외부에서 메뉴의 상태를 제어하기 위한 바인딩 변수입니다.
    * `config`: `SideMenuConfiguration` 인스턴스를 저장하여 메뉴 설정을 적용합니다.
    * `content`: `@ViewBuilder`를 사용하여 메뉴 내부에 표시될 커스텀 뷰를 받습니다.
    * `@State private var dragController`: 드래그 상태를 관리하는 `MenuDragController` 인스턴스입니다.
    * `body`:
        * `ZStack`을 사용하여 메인 컨텐츠 위에 메뉴와 오버레이를 배치합니다.
        * `GeometryReader`: 메뉴 위치 계산 및 드래그 처리에 사용될 수 있습니다 (현재 코드에서는 `handleDragEnd`의 파라미터로 전달되지만 직접 사용되진 않음).
        * **Dimmed Overlay:** 메뉴가 열렸을 때 나타나는 반투명 검은색 배경입니다. 탭하면 `closeMenu()`를 호출하여 메뉴를 닫습니다.
        * **Menu Content:** 사용자가 제공한 `content` 뷰를 표시합니다. `frame`, `background`, `shadow`, `offset` 등을 `config` 값을 이용해 설정합니다.
        * **Drag Gesture:** 메뉴 컨텐츠에 `DragGesture`를 추가하여 `MenuDragController`를 통해 드래그를 처리하고, 드래그가 끝나면 `handleDragEnd`를 호출합니다.
    * `computeMenuPosition()`: `isOpen` 상태와 `dragController`의 현재 드래그 위치를 기반으로 메뉴의 x축 `offset`을 계산합니다.
    * `handleDragEnd()`: 드래그가 끝났을 때, `dragController.shouldToggleMenuState`를 호출하여 상태 변경 여부를 결정하고, 필요시 `isOpen` 값을 토글합니다. 항상 `dragController.resetDrag()`를 호출하여 드래그 상태를 초기화합니다.
    * `closeMenu()`, `openMenu()`, `toggleMenu()`: `isOpen` 상태를 애니메이션과 함께 변경하고 드래그 상태를 초기화하는 공개/비공개 헬퍼 함수들입니다.
    * `.onChange(of: isOpen)`: `isOpen` 값이 외부 또는 내부 로직에 의해 변경될 때, 드래그 상태를 깔끔하게 초기화하여 예기치 않은 위치 이동을 방지합니다.
* **`View Extension (.sideMenu)`:**
    * 어떤 `View`에도 `.sideMenu(...)` 수정자를 쉽게 적용할 수 있도록 제공하는 확장입니다.
    * 내부적으로 `ZStack`을 사용하여 원본 뷰와 `SideMenu` 뷰를 함께 배치합니다.

## 🤝 기여하기

개선 사항이나 버그 수정에 대한 제안은 언제나 환영입니다! 이슈를 등록하거나 Pull Request를 보내주세요.

## 📄 라이선스

MIT License? 
