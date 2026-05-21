# Changelog

BetterMyself 的版本变化记录。这里按版本整理重要变化，方便之后回看某个能力是在什么时候加入或调整的。

## [0.1.2] - 2026-05-21

### Added

- 增加“今天的回应”AI 模块，可基于当天记录生成一段反馈。
- 增加 DeepSeek API 调用，使用 `deepseek-v4-flash`。
- 增加 App 内 API Key 保存入口，密钥仅保存在本机 Keychain。

### Changed

- 将 AI 回应模块收敛为按钮，API Key 设置入口下沉为测试配置。
- 删除记录时不再弹出二次确认。
- 将 DeepSeek 请求超时缩短到 20 秒，并改进网络错误提示。
- 保存后自动请求当天 AI 回应，并用淡入淡出替换旧回应。
- 将保存反馈固定为“我记下来了”。

## [0.1.1] - 2026-05-21

### Added

- 在记录详情页右上角增加更多选项菜单，可通过确认弹窗删除当前记录。

## [0.1.0] - 2026-05-21

### Added

- 新建 iOS 原生 App 工程，使用 SwiftUI 和 SwiftData。
- 增加本机记录模型 `Entry`，保存内容、创建时间和更新时间字段。
- 增加输入页：打开 App 后默认进入输入体验。
- 增加本机保存：输入内容后可保存到 App 沙盒中的 SwiftData 本地存储。
- 增加回看页：按日期分组、按时间倒序展示记录。
- 增加详情页：点击单条记录后查看完整内容。
- 增加 `.gitignore`，排除 `.DS_Store` 和常见 Xcode 本地构建/用户状态文件。

### Changed

- 保存动作文案从“收起来”调整为“收起”，后续又调整为“说完了”。
- 输入页视觉调整为黑白灰、低对比度、大留白、极简风格。
- 去掉输入页副标题“想说什么都可以”。
- 顶部文案调整为“Hi，你今天想说点什么？”。
- 输入框从大文本区域调整为居中的长条输入框，并支持随内容自动展开。
- 输入框初始高度调整为至少三行文字高度。
- “说完了”按钮从输入框内部移到输入框下方右侧。

### Fixed

- 修复 SwiftUI 自定义颜色在 `foregroundStyle` 中的类型推断报错。
- 调整时间线导航写法，避免 SwiftData 模型用于 `NavigationLink(value:)` 时产生不必要约束。
- 调整日期格式化工具，避免共享可变 `DateFormatter` 在 Swift 6 下带来的潜在问题。

### Verified

- `swiftc -parse BetterMyself/*.swift` 通过。
- `xcodebuild -project BetterMyself.xcodeproj -scheme BetterMyself -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` 通过。

### Not Included

- 暂不支持账号、云同步、iCloud 同步或导出。
- 暂不支持图片、语音、心情选择、标签、统计或 AI 功能。
- 暂未做 App 图标和正式分发配置。
