# AuthKey

基于时间的一次性密码（TOTP）认证应用，支持 Android 与鸿蒙系统。

## 功能特性

- **TOTP 验证码生成** — 支持 HMAC-SHA1/SHA256/SHA512 算法，严格遵循 RFC 6238 标准
- **二维码扫描** — 快速扫描 `otpauth://` 二维码添加账户
- **手动输入** — 支持手动输入发行方、账户名、密钥等信息
- **安全存储** — 密钥数据通过 FlutterSecureStorage 加密存储（AES-256）
- **生物识别解锁** — 支持指纹/人脸验证，遵循手机安全设置逻辑（依赖转移密码）
- **转移密码保护** — SHA-256 哈希存储，导出数据时需验证密码
- **数据转移** — 支持导出/导入 JSON 文件，通过系统分享功能传输
- **主题切换** — 跟随系统 / 浅色模式 / 暗色模式
- **跨平台** — 支持 Android 6.0+、鸿蒙OS 2.0、鸿蒙NEXT

## 安全设计

| 层级 | 机制 | 说明 |
|------|------|------|
| 密钥存储 | FlutterSecureStorage | Android EncryptedSharedPreferences (AES-256) |
| 转移密码 | SHA-256 哈希 | 不存明文，只存哈希值 |
| 生物识别 | local_auth | 依赖转移密码，类似手机"指纹+PIN"逻辑 |
| 网络安全 | 禁止明文传输 | networkSecurityConfig 配置 |
| 备份 | 禁止自动备份 | allowBackup=false, fullBackupContent=false |

### 生物识别与转移密码的关系

遵循手机安全设置的逻辑：

- 开启生物识别**必须先设置转移密码**（类似开指纹需先设 PIN）
- 开启生物识别时需**验证转移密码**
- 导出数据时：优先生物识别 → 失败可回退到转移密码
- 移除转移密码时：自动关闭生物识别

## 安装

### Android

1. 下载 `AuthKey-v1.0.0-release.apk`
2. 在手机设置中允许"未知来源应用安装"
3. 安装 APK

### 鸿蒙OS 2.0

鸿蒙OS 2.0 兼容 Android APK，安装方式与 Android 相同。

### 鸿蒙NEXT

鸿蒙NEXT 需要通过 Flutter ohos 分支构建 HAP 包，后续支持。

## 开发

### 环境要求

- Flutter 3.32+ (stable)
- Dart 3.8+
- Android SDK: compileSdk 36, minSdk 23, targetSdk 34
- NDK 27.0.12077973

### 构建与运行

```bash
# 获取依赖
flutter pub get

# 调试模式运行
flutter run

# 打包 release APK
flutter build apk --release
```

## 技术栈

- **Flutter** — 跨平台 UI 框架
- **Provider** — 状态管理
- **crypto** — TOTP 核心算法 (HMAC-SHA1/SHA256/SHA512)
- **flutter_secure_storage** — 加密持久化
- **local_auth** — 生物识别
- **mobile_scanner** — 二维码扫描 (ML Kit)
- **share_plus** — 系统分享
- **file_picker** — 文件选择

## 开源许可

详见 [开放源代码许可](lib/screens/oss_licenses_screen.dart) 页面。

## 作者

- **开发者**：且试新茶趁年华
- **GitHub**：[ZevanFt](https://github.com/ZevanFt)
- **邮箱**：burachenji@126.com

## 许可证

本项目基于 [GNU General Public License v3.0](LICENSE) 开源。

© 2025 且试新茶趁年华
