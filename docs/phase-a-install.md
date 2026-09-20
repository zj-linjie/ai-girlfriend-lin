# 阶段 A · 安装与配置说明(可复现)

> 目标:在 M4 / 16 GB Mac 上完成可复现的 AIRI 桌面部署,搭起"云端 LLM + 语音输入 + TTS"最小语音链路。
> 本文档记录的是**实际执行过的步骤与版本**,照做即可复现。

## 1. 环境基线

| 项目 | 值 |
| --- | --- |
| 机型 | Mac mini |
| 芯片 | Apple M4 |
| 内存 | 16 GB |
| macOS | 27.0(26A428) |
| Homebrew | 7.0.4(`/opt/homebrew`) |

验证命令:

```bash
system_profiler SPHardwareDataType | grep -E "Chip|Memory"
sw_vers
brew --version
```

## 2. AIRI 版本决策

| 渠道 | 版本 | 说明 |
| --- | --- | --- |
| Homebrew Cask(官方发行渠道)✅ 采用 | **0.11.3**(稳定版) | `brew install --cask airi`,版本锁定、可复现,cask 描述 "AI companion and VTuber application",要求 macOS ≥ 12 |
| GitHub Releases(moeru-ai/airi) | v0.12.0-beta.5(latest,beta) | 有 `darwin-arm64.dmg`,但为 beta,不作为基线 |

**决策**:基线采用 cask 稳定版 0.11.3,保证可复现;若实测发现 0.11.3 存在阻断性缺陷,再评估切换 GitHub beta 并重新记录版本。

- 上游仓库:[moeru-ai/airi](https://github.com/moeru-ai/airi)(≈49k stars)
- 许可:**MIT**(实测核对自仓库 LICENSE 文件)——AIRI 本体使用与二次定制无许可障碍
- Apple Silicon:提供 `darwin-arm64` / `arm64-mac` 官方构建 ✅

## 3. 安装

```bash
brew install --cask airi
# 验证
ls /Applications/AIRI.app
brew list --cask --versions airi
```

下载体积约 870 MB(内含 Live2D/Spine 等运行时资源),耐心等待。

### 首次启动

```bash
open -a AIRI
```

- 若 Gatekeeper 弹出"已下载"确认框,点"打开"即可(cask 安装的 app 带正规签名流程,一般不会遇到)。
- 首次启动进入欢迎引导:**右上角地球按钮可切换界面语言**。
- 主窗口是悬浮的角色舞台;若找不到窗口,从**系统托盘(菜单栏)图标**选 Show 找回。

## 4. 权限

| 权限 | 触发时机 | 操作 |
| --- | --- | --- |
| 麦克风 | 首次启用语音输入/听觉模块时系统弹窗 | 系统设置 → 隐私与安全性 → 麦克风 → 勾选 AIRI。若漏点,手动补勾后**重启 AIRI** |
| 辅助功能/录屏 | 本阶段不需要(不使用视觉/桌面控制模块) | 跳过 |

## 5. 最小语音链路配置

AIRI 设置入口:主窗口右下角 Controls Island → "Open settings",或系统托盘菜单 → Settings。
设置窗口的 **Providers 页**分五类:Chat / Vision / Speech / Transcription / Artistry。**本阶段只配置 Chat、Transcription(语音识别)、Speech(语音合成)三类。**

### 5.1 Chat(LLM)——三选一

首次引导支持:OpenRouter、OpenAI Compatible、DeepSeek、Ollama(本地)、Google Gemini、Anthropic。

| 选项 | 说明 | 本阶段评价 |
| --- | --- | --- |
| DeepSeek | 直连,国内网络稳定,便宜 | ✅ 推荐作为默认链路 |
| OpenRouter | 聚合,可换多家模型 | 备选,便于横向对比 |
| OpenAI Compatible | 任意兼容端点(含中转) | 备选 |

配置字段见 [config/airi-providers.example.md](config/airi-providers.example.md)。模型选一个价格透明的对话模型即可,**不要**为本阶段开启推理增强/超长上下文等高价选项——本阶段要测的是"现成链路够不够用",不是模型上限。

### 5.2 Transcription(语音识别)

在 Providers 页 Transcription 分类下选择一个云端识别提供商并填 Key(以设置页实际列出的支持项为准;AIRI 内置浏览器级识别可作为兜底)。**明确不引入本地 Whisper 等系统**——那是"全本地"目标的事,与阶段 A 无关。

### 5.3 Speech(TTS)

在 Providers 页 Speech 分类下选择一个云端 TTS 并配置。选择标准:延迟低、可试听、价格可查。同样**不引入本地语音合成**。

### 5.4 模块开关(Modules 页)

确认 **Speech(语音输出)、Hearing(听觉)** 两个模块处于启用状态;Consciousness 指向已配置的 Chat 提供商。其余模块(视觉、记忆、Discord、Minecraft 等)本阶段**全部不启用**,避免干扰资源与延迟测量。

## 6. 角色素材与授权

- 本阶段**仅使用 AIRI 内置默认角色**(Live2D/VRM,随发行版附带,MIT 许可框架下分发)。
- 通过 Controls Island → "Switch Profile" 可切换角色卡,不额外下载来路不明的模型。
- **不引入任何真人形象素材**——真人 Avatar 属于阶段 B/C,且有独立的授权与门禁要求。

## 7. 密钥与隐私约定

- 所有 API Key 只填写在 AIRI 本地设置中(AIRI 为本地应用,配置保存在本机用户目录下,见 §9)。
- 任何 Key、录音、屏幕录制、含个人信息的日志**不入仓库**(`.gitignore` 已排除)。
- 仓库内只允许出现脱敏样例(见 `config/airi-providers.example.md`)。

## 8. 明确排除项(本阶段)

- ❌ Whisper / OmniVoice / MuseTalk 等本地化语音或数字人系统
- ❌ Windows/NVIDIA 项目移植、重写 AIRI
- ❌ GPT Live / OpenAI Realtime
- ❌ 跨会话记忆、复杂 Persona 工程
- ❌ 桌面自动控制(视觉/计算机使用模块)

## 9. 配置数据存放位置(本机,已实测确认)

AIRI 为 **Electron** 桌面应用,用户数据目录(首次启动后已确认):

```bash
~/Library/Application Support/ai.moeru.airi/
```

目录内含 `app-config.json`、`app-options.json`、各 Provider 配置(含密钥)、浏览器缓存等。
该目录属于本机隐私数据,**不要**整体拷贝进仓库;需要分享配置时,按脱敏样例格式手工摘录。

## 10. 回滚/卸载

```bash
brew uninstall --cask airi
# 彻底清理(含本机设置与密钥):
rm -rf ~/Library/"Application Support"/ai.moeru.airi
```
