# AIRI 提供商配置样例(脱敏)

> 本文件是**脱敏样例**,所有值均为占位符。真实 Key 只填在 AIRI 设置界面中,不入仓库。
> 入口:Controls Island → Open settings → Providers 页。

## 实际采用的链路(2026-09-20)

| 类别 | Provider | 端点/模型 | 状态 |
| --- | --- | --- | --- |
| Chat(LLM) | OpenAI Compatible → Agnes 聚合 | `https://<your-aggregator>/v1` + Key | ✅ 已配通,打字聊天正常 |
| Vision | 同 Agnes | 同上 | ✅ 已配置 |
| Transcription(STT) | OpenAI Compatible → SiliconFlow | `https://api.siliconflow.cn/v1/`,模型 `FunAudioLLM/SenseVoiceSmall` | ⏳ 待配置(见下) |
| Speech(TTS) | **Volcengine(火山引擎/豆包音色)** | 火山"语音技术"应用 App ID + API Key | ⏳ 待配置(见下) |
| Artistry(画图) | — | — | ⛔ 阶段 A 跳过,与语音对话无关 |

## Chat(对话 LLM)

| 字段 | 值(样例) |
| --- | --- |
| Provider | `OpenAI Compatible` |
| Base URL | `https://<your-aggregator>/v1` |
| API Key | `sk-xxxxxxxxxxxxxxxxxxxxxxxx`(真实 Key 只存本地) |
| Model | 任选价格透明的对话模型 |

## Transcription(语音识别)

**踩坑记录**(2026-09-20 实测):
- AIRI 桌面版首次配置后,Transcription 默认挂在 **AIRI 官方通道(official-provider-transcription)** 上,未配置可用云端 STT,语音输入报 "failed to transcribe";需手动切换。
- 桌面版(Electron)里 `browser-web-speech-api`(浏览器语音识别)不可用,不要选。
- Agnes 聚合端点**不支持音频转写**(`/v1/audio/transcriptions` 返回 503 no channel),不能复用 Chat 的 Key。

**配置方法**(推荐 SiliconFlow,国内直连、SenseVoiceSmall 免费额度、已实测可达 0.46s):

| 字段 | 值(样例) |
| --- | --- |
| Provider | Transcription 页的 `OpenAI Compatible`(音频转写) |
| Base URL | `https://api.siliconflow.cn/v1/` |
| API Key | `<SiliconFlow 的 Key,真实 Key 只存本地>` |
| Model | `FunAudioLLM/SenseVoiceSmall` |

备选:Groq 的 `whisper-large-v3`(免费额度,已实测可达 0.8s,Base URL `https://api.groq.com/openai/v1/`)。

## Speech(语音合成)

**采用:火山引擎豆包 TTS**(AIRI 原生支持,中文音色自然度高;识别与合成用不同供应商完全可行):

1. 登录[火山引擎控制台](https://console.volcengine.com/),进入**语音技术**,创建语音应用(需实名;合成音色有免费试用额度),确认应用已**开通语音合成**服务。
2. AIRI 设置 → 服务商 → 语音合成(Speech)→ **Volcengine**,填同一应用下的 **App ID + API Key**(两者必须来自同一应用,否则验证失败)。
3. 点 **Ping API** 验证连通;成功后选择豆包音色(默认 `BV001_streaming`,可试听更换中文音色)。
4. 到 设置 → 发声 启用该 TTS。

> AIRI 桌面版不配 TTS 时 Speech 处于 `speech-noop`(空占位,永远不出声)。

**备选**:SiliconFlow CosyVoice2(一个 Key 连 STT+TTS,省事):
Provider 选 Speech 页的 OpenAI Compatible,Base URL `https://api.siliconflow.cn/v1/`,模型 `FunAudioLLM/CosyVoice2-0.5B`,音色 `FunAudioLLM/CosyVoice2-0.5B:alex`。

**关于豆包识别(ASR)的踩坑结论**(2026-09-20 查证):AIRI 0.11.3 的 Transcription 分类**没有火山条目**,且火山方舟的语音识别只有自有 WebSocket/HTTP 接口、无官方 OpenAI 兼容 `/v1/audio/transcriptions` 端点——所以**豆包识别接不进 AIRI,识别侧用 SiliconFlow SenseVoice**(上面 Transcription 一节),不必再找。

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
