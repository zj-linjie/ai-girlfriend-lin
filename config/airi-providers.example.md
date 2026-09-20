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

### ⚠️ 豆包 TTS 结论:阶段 A 放弃(2026-09-20 两轮实测后定案)

1. AIRI 原生"火山引擎"卡片默认走第三方中转 `unspeech.hyp3r.link`,其私有 SaaS 层不认火山原始凭据,报 `401 UPSTREAM_ERROR: load grant: requested grant not found in SaaS storage`。
2. 尝试绕开中转、用 OpenAI Compatible 卡直连火山方舟(`https://ark.cn-beijing.volces.com/api/v3/`)→ 实测 **401**。查证后确认:**方舟的语音模型走自有 HTTP/WebSocket 协议,只有 chat 是 OpenAI 兼容**;豆包语音服务("快捷API接入"的 Key,openspeech.bytedance.com)同样是自有协议,且**语音 Key 与方舟 Key 官方明确互不通用**。社区存在专门的"豆包转 OpenAI 格式"桥接项目,反证官方无兼容端点。
3. 自建桥接代理违反阶段 A"不造轮子"原则 → **豆包音色搁置**;若后续强烈需要,另立 issue。

> 教训:方舟网关"先鉴权后路由",用假 Key 探测任何路径都返回相同 401,不能据此判断端点存在;AIRI 的"配置验证成功"只是浅校验,不代表 Key/链路真实可用。

### 采用:SiliconFlow CosyVoice2(已验证可达 0.46s,与 STT 同一家、同一个 Key)

| 字段 | 值(样例) |
| --- | --- |
| Provider | Speech 页的 `OpenAI Compatible`(音频合成) |
| Base URL | `https://api.siliconflow.cn/v1/` |
| API Key | `<SiliconFlow 的 Key,与 Transcription 同一把>` |
| Model | `FunAudioLLM/CosyVoice2-0.5B` |
| Voice | `FunAudioLLM/CosyVoice2-0.5B:alex`(试听后可换其他中文音色) |

> 不配 TTS 时 AIRI 的 Speech 处于 `speech-noop`(空占位,永远不出声)。

**豆包识别(ASR)同一定案**:方舟/豆包语音的 ASR 亦为自有协议、无官方 OpenAI 兼容端点 → 识别侧采用 SiliconFlow `FunAudioLLM/SenseVoiceSmall`(见 Transcription 一节)。

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
