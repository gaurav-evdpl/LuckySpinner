# LuckySpinner

A reusable **SwiftUI spinner wheel** that randomly picks one name from a list. Tap the
spin button, watch the wheel rotate with a smooth animation, and see the winner
announced with a confetti burst — all with **zero external dependencies**.

## Features

- 🎡 Circular spinner wheel drawn entirely in SwiftUI (pie slices + labels)
- 🎯 Fixed top pointer that always lands exactly on the selected name
- 🎉 Lightweight, built-in confetti (no third-party libraries)
- 🎨 Fully customizable via `LuckySpinnerConfig` (size, duration, colors, and more)
- 🌈 Ready-made color themes (`classic`, `pastel`, `ocean`)
- 🧩 Simple, beginner-friendly public API
- 📱 Works on iOS 15+ and macOS 12+
- ✅ Unit tested and SwiftUI-preview friendly

## Installation

Add LuckySpinner using **Swift Package Manager**:

```text
Xcode → File → Add Package Dependencies → paste GitHub package URL
```

Or add it directly to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/LuckySpinner.git", from: "1.0.0")
]
```

## Usage

```swift
import SwiftUI
import LuckySpinner

struct ContentView: View {
    var body: some View {
        LuckySpinnerView(
            names: ["Gaurav", "Rahul", "Priya", "Amit"],
            title: "Who will present today?",
            buttonTitle: "Spin"
        ) { selectedName in
            print(selectedName)
        }
        .padding()
    }
}
```

## Custom configuration

Customize the look and behavior with `LuckySpinnerConfig`:

```swift
let config = LuckySpinnerConfig(
    wheelSize: 320,
    spinDuration: 3,
    extraSpins: 6,
    showsConfetti: true,
    buttonCornerRadius: 16,
    selectedText: "Selected",
    colors: [.red, .blue, .green, .orange, .purple]
)

LuckySpinnerView(
    names: ["Gaurav", "Rahul", "Priya", "Amit"],
    title: "Who is lucky today?",
    buttonTitle: "Spin",
    config: config,
    onSelection: { name in
        print("Selected:", name)
    }
)
```

You can also start from the built-in themes:

```swift
var config = LuckySpinnerConfig.default
config.colors = LuckySpinnerTheme.pastel
```

## Configuration options

| Property             | Type        | Default            | Description                                   |
| -------------------- | ----------- | ------------------ | --------------------------------------------- |
| `wheelSize`          | `CGFloat`   | `300`              | Width/height of the wheel in points           |
| `spinDuration`       | `Double`    | `3`                | Length of the spin animation in seconds       |
| `extraSpins`         | `Int`       | `5`                | Extra full rotations before stopping          |
| `showsConfetti`      | `Bool`      | `true`             | Whether confetti plays after a spin           |
| `buttonCornerRadius` | `CGFloat`   | `14`               | Corner radius of the spin button              |
| `selectedText`       | `String`    | `"Selected"`       | Label shown above the winning name            |
| `colors`             | `[Color]`   | `Theme.classic`    | Slice colors (repeats if fewer than names)    |

## Requirements

- iOS 15.0+ / macOS 12.0+
- Swift 5.9+
- Xcode 15+

## License

LuckySpinner is available under the MIT License. See the [LICENSE](LICENSE) file for details.
