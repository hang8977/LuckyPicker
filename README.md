# LuckyPicker - 决策转盘应用

LuckyPicker是一个iOS应用，帮助用户在多个选项之间做出随机决策。用户可以添加自定义选项，应用会通过旋转转盘的方式随机选择一个结果。

## 项目概述

这是一个使用SwiftUI开发的iOS应用，主要功能包括：

- 创建和管理决策选项
- 通过旋转转盘随机选择一个选项
- 查看历史决策记录
- 自定义应用设置

## 项目结构

```
LuckyPicker/
├── Assets.xcassets/         # 资源文件，包括应用图标和其他图像资源
├── LuckyPickerApp.swift     # 应用入口文件
├── ContentView.swift        # 主内容视图，管理标签页导航
├── Views/                   # 视图文件夹
│   ├── Components/          # 可复用组件
│   │   └── WheelView.swift  # 转盘组件实现
│   ├── HomeView.swift       # 主页视图
│   ├── AddOptionView.swift  # 添加选项视图
│   ├── ResultView.swift     # 结果展示视图
│   ├── HistoryView.swift    # 历史记录视图
│   └── SettingsView.swift   # 设置视图
├── Models/                  # 数据模型
│   └── OptionModel.swift    # 选项数据模型和管理器
└── Utils/                   # 工具类
    └── ColorExtension.swift # 颜色扩展工具
```

## 核心功能

### 1. 决策转盘 (WheelView)

`WheelView.swift` 实现了一个可旋转的转盘组件，具有以下特点：

- 根据用户添加的选项动态生成扇形区域
- 支持触发旋转动画
- 随机选择一个结果并通过回调函数返回
- 支持自定义颜色和文本显示

### 2. 选项管理 (OptionModel)

`OptionModel.swift` 定义了选项数据模型和管理器：

- `Option` 结构体：表示一个选项，包含文本内容和颜色
- `OptionsManager` 类：管理选项的添加、删除和排序
- 支持历史记录的保存和加载

### 3. 用户界面

- `HomeView`：主页面，展示转盘和开始按钮
- `AddOptionView`：添加和管理选项的界面
- `ResultView`：展示随机选择的结果
- `HistoryView`：查看历史决策记录
- `SettingsView`：应用设置界面

## 最近的改进

1. **转盘文本显示优化**：
   - 修复了文本在扇形中的位置问题，使其居中显示
   - 添加了文本背景，提高了可读性
   - 解决了类型转换错误

2. **导航栏优化**：
   - 优化了AddOptionView的导航栏，去除了重复的返回按钮
   - 使用更美观的箭头图标替代文字"返回"

3. **UI美化**：
   - 添加了应用图标
   - 改进了颜色对比度和可读性

## 技术实现细节

### 转盘实现

转盘使用SwiftUI的自定义Shape和动画实现：

- `SlicePath` 形状用于创建扇形
- 使用 `rotationEffect` 和 `withAnimation` 实现旋转效果
- 通过几何计算确保文本正确显示在扇形中

### 状态管理

应用使用SwiftUI的状态管理机制：

- `@State` 用于组件内部状态
- `@Binding` 用于组件间传递状态
- `@EnvironmentObject` 用于全局状态管理（如选项管理器）

### 数据持久化

使用UserDefaults存储用户数据：

- 保存用户添加的选项
- 记录历史决策结果
- 存储用户设置

## 未来计划

- 添加更多自定义选项（如转盘速度、动画效果）
- 支持导出和分享决策结果
- 添加更多主题和视觉样式
- 实现iCloud同步功能

## 开发环境

- Xcode 15+
- Swift 5.9+
- iOS 17.0+
- SwiftUI 4.0+

## 如何使用

1. 在主页面点击右上角的"+"按钮添加选项
2. 在添加选项页面输入选项内容并点击"+"或"添加新选项"按钮
3. 返回主页面，点击"开始选择"按钮旋转转盘
4. 转盘停止后，会显示随机选择的结果
5. 在历史记录页面可以查看过去的决策结果

## 贡献指南

如果您想为项目做出贡献，请遵循以下步骤：

1. Fork 项目
2. 创建您的特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交您的更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 打开一个 Pull Request 