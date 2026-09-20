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

### ⚠️ 踩坑:AIRI 原生"火山引擎"卡片不可用(2026-09-20 实测)

AIRI 的 Volcengine TTS 默认把凭据发往第三方中转 `unspeech.hyp3r.link`(unspeech 协议),该实例带私有 SaaS 层,只认它自己登记的凭据("grant");填入火山原始凭据会报:
`Remote sent 401 response ... UPSTREAM_ERROR: load grant: requested grant not found in SaaS storage`。
**不要在该卡片上继续排查**;页面里出现 ElevenLabs 的测试文案/声线名(如 "Charlie")只是 UI 模板默认值,可忽略。

### 方案一(采用):OpenAI Compatible 直连火山方舟(豆包 TTS)

已实测方舟存在 OpenAI 兼容端点 `/api/v3/audio/speech`(探测返回 401 路由有效,直连、不经过中转):

| 字段 | 值(样例) |
| --- | --- |
| Provider | Speech 页的 `OpenAI Compatible`(音频合成) |
| Base URL | `https://ark.cn-beijing.volces.com/api/v3/`(结尾必须带 `/`) |
| API Key | `<火山方舟 API Key>`(方舟控制台创建;与"语音技术"应用的 App ID/Token 是两套体系,用方舟的) |
| Model | `doubao-seed-tts`(以方舟控制台「开通管理」显示的模型 ID 为准,如 `doubao-seed-tts-2.0`) |
| Voice | 豆包音色 ID,如 `zh_female_cancan_schoolgirl` |

前提:注册火山方舟 + 实名 → **「API Key 管理」创建 API Key**(⚠️ 不是"语音技术应用"的 App ID / Access Token / Secret Key——那套是旧版凭据,给 AIRI 原生火山卡片用的,本链路用不上)→ 在「开通管理」开通 doubao-seed-tts 模型(**音色列表为空/服务未开通时调用会报模型未开通,先开通**)。若测试报 model not found,按控制台显示的 ID 改模型名即可。

### 方案二(保底):SiliconFlow CosyVoice2

Provider 选 Speech 页 OpenAI Compatible,Base URL `https://api.siliconflow.cn/v1/`,模型 `FunAudioLLM/CosyVoice2-0.5B`,音色 `FunAudioLLM/CosyVoice2-0.5B:alex`。

> 不配 TTS 时 AIRI 的 Speech 处于 `speech-noop`(空占位,永远不出声)。

**豆包识别(ASR)修正结论**(2026-09-20 实测更新):方舟同样存在 OpenAI 兼容端点 `/api/v3/audio/transcriptions`(探测 401 路由有效)。即:拿同一把方舟 Key,在 Transcription 页选 OpenAI Compatible、同 Base URL、模型填方舟的豆包识别模型 ID(以控制台为准)——**理论上全豆包链路可行,识别模型 ID 待真 Key 验证**;若报模型不存在,Transcription 回退 SiliconFlow `FunAudioLLM/SenseVoiceSmall`。

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
