# AIRI 提供商配置样例(脱敏)

> 本文件是**脱敏样例**,所有值均为占位符。真实 Key 只填在 AIRI 设置界面中,不入仓库。
> 入口:Controls Island → Open settings → Providers 页。

## Chat(对话 LLM)

采用 DeepSeek 作为默认链路:

| 字段 | 值(样例) |
| --- | --- |
| Provider | `DeepSeek` |
| API Key | `sk-xxxxxxxxxxxxxxxxxxxxxxxx`(真实 Key 只存本地) |
| Base URL | `https://api.deepseek.com`(默认,无需改) |
| Model | `deepseek-chat` |

备选:OpenRouter(聚合多模型)、OpenAI Compatible(任意兼容端点)。

```text
# OpenRouter 样例
Provider: OpenRouter
API Key:  sk-or-v1-xxxxxxxxxxxxxxxxxxxxxxxx
Model:    openai/gpt-4o-mini   # 示意,任选价格透明的小模型即可
```

## Transcription(语音识别)

| 字段 | 值(样例) |
| --- | --- |
| Provider | 以 AIRI 设置页 Transcription 分类实际列出的云端支持项为准 |
| API Key | `<占位符,真实 Key 只存本地>` |
| Language | `zh-CN`(按实际对话语言) |

兜底:AIRI 内置浏览器级识别(Web Speech API)不需要 Key,可作对照,但精度与稳定性以云端为准。

## Speech(语音合成)

| 字段 | 值(样例) |
| --- | --- |
| Provider | 以 AIRI 设置页 Speech 分类实际列出的云端支持项为准 |
| API Key / Region | `<占位符,真实 Key 只存本地>` |
| Voice | 任选一个中文女声/角色声线(以试听效果定) |

## Modules(模块开关)

| 模块 | 状态 | 原因 |
| --- | --- | --- |
| Consciousness(意识) | ✅ 指向上述 Chat 提供商 | 核心对话 |
| Speech(语音输出) | ✅ 启用 | 核心链路 |
| Hearing(听觉) | ✅ 启用 | 核心链路 |
| Vision / Memory / Discord / Minecraft / MCP 等 | ❌ 全部关闭 | 避免干扰延迟与资源测量 |

## 校验清单

- [ ] Chat 页可完成一轮文本对话(Open Chat 窗口发消息有回复)
- [ ] Speech 试听按钮能出声
- [ ] 按住语音输入说话,转录文本出现在聊天框
- [ ] 设置中的 Key 未出现在任何 git 跟踪文件里(`git grep -i "sk-"` 无真实 Key 命中)
