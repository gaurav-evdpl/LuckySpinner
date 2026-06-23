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

### In Xcode

```text
Xcode → File → Add Package Dependencies → paste GitHub package URL
```

Paste this URL:

```text
https://github.com/gaurav-evdpl/LuckySpinner.git
```

Then choose a dependency rule (e.g. **Up to Next Major Version** `1.0.0`, or **Branch** `main` if no version is tagged yet) and add the **LuckySpinner** library to your app target.

### In Package.swift

Add LuckySpinner to your package's `dependencies`:

```swift
dependencies: [
    // Pin to a released version once a tag exists:
    .package(url: "https://github.com/gaurav-evdpl/LuckySpinner.git", from: "1.0.0")

    // Or, until a version is tagged, track the main branch:
    // .package(url: "https://github.com/gaurav-evdpl/LuckySpinner.git", branch: "main")
]
```

Then add `"LuckySpinner"` to your target's dependencies:

```swift
.target(
    name: "YourApp",
    dependencies: ["LuckySpinner"]
)
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
