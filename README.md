# Linebreak

A macOS screenshot clothesline with a **pull-to-break gesture** for clearing every image. This is an independent fork of [Tendedero by Alejandro Buján](https://github.com/alejandrobujan/tendedero), with a different app name, icon, preferences and screenshot inbox.

## 拉断绳子，清空图片

1. 将光标移到图片之间的绳子上，光标变为抓手。
2. 按住向下拉：绳子和图片跟随，接近阈值时断点开始起毛。
3. 绳子明显起毛、达到拉断阈值后松手，绳子从抓取的位置断开，两侧图片接连滑向断口并掉出屏幕。
4. 拉动不足、拉回阈值以内或按 Esc，绳子回弹，图片保留。

交互没有按钮或文字提示。最后一张图片滑离断口后，绳端短暂停留并在 180 毫秒内淡出，图片继续自然下落。

清空包括屏幕外的图片。操作期间新截的图会等待动画结束后挂上，不会被这次清空影响。系统开启「减少动态效果」时跳过松手后的动画。

文件处理沿用原项目规则：Linebreak 收件目录中的文件移入废纸篓；来自桌面或其他目录的文件只从绳上移除。删除失败的图片会保留，系统提示音表示有未清除的项目。

## Build and run

Requires macOS 14+ and Apple Command Line Tools. Swift Testing tests need Swift 6+.

```sh
scripts/build-app.sh
open build/Linebreak.app
```

The build produces a universal Apple silicon / Intel app. Set `SIGN_IDENTITY=-` for an ad hoc local development build. The build script falls back to an installed macOS 26 SDK if the macOS 27 Command Line Tools SDK is missing its SwiftUI macro plugin.

Use one screenshot manager at a time if you enable screenshot-inbox mode. Linebreak stores its own captured files in `~/Library/Application Support/Linebreak/Screenshots`; it does not import Tendedero's history.

## Development

```sh
swift test
swift scripts/check-strings.swift
scripts/build-app.sh debug
open build/Linebreak.app --args --rope-demo
```

The opt-in debug demo generates five temporary sample images and uses a separate history. It does not start screenshot or clipboard watchers or apply screenshot settings. Choose “Reset demo” from its menu-bar icon to reset it. The source module remains named `Tendedero` to keep upstream integration straightforward.

Tests cover anchored endpoints, threshold cancellation, the actual break position, sliding/falling trajectories, batch history persistence, offscreen images, new-image preservation and trash failures. See [native validation notes](docs/rope-break.md) for implementation details and manual checks.

## Credits and license

Based on [Tendedero](https://github.com/alejandrobujan/tendedero), copyright © 2026 Alejandro Buján. Source code is MIT licensed; see [LICENSE](LICENSE). This fork is not endorsed by the original author. Linebreak's app icon is original artwork in `scripts/make-linebreak-icon.swift`. Upstream name/icon artwork is not used in the built Linebreak app; historical upstream documentation and artwork remain in the source tree for provenance.
